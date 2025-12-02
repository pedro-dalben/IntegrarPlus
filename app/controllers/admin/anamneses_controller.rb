# frozen_string_literal: true

module Admin
  class AnamnesesController < BaseController
    before_action :set_anamnesis,
                  only: %i[show edit update start complete mark_attended mark_no_show cancel_anamnesis print_pdf]
    before_action :convert_date_params, only: %i[create update]

    def index
      authorize Anamnesis, policy_class: Admin::AnamnesisPolicy

      if params[:query].present?
        begin
          search_service = AdvancedSearchService.new(Anamnesis)
          filters = build_search_filters
          options = build_search_options

          search_results = search_service.search(params[:query], filters, options)

          page = (params[:page] || 1).to_i
          per_page = 20
          offset = (page - 1) * per_page

          @anamneses = search_results[offset, per_page] || []
          @pagy = Pagy.new(count: search_results.length, page: page, items: per_page)
        rescue StandardError => e
          Rails.logger.error "Erro na busca avançada: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          @anamneses = perform_local_search
          @pagy, @anamneses = pagy(@anamneses, items: 20)
        end
      else
        @anamneses = perform_local_search
        @pagy, @anamneses = pagy(@anamneses, items: 20)
      end

      respond_to do |format|
        format.html do
          render partial: 'search_results', layout: false if request.xhr?
        end
        format.json { render json: { results: @anamneses, count: @pagy.count } }
      end
    end

    def show
      authorize @anamnesis, policy_class: Admin::AnamnesisPolicy
    end

    def new
      @beneficiary = Beneficiary.find(params[:beneficiary_id]) if params[:beneficiary_id].present?
      @anamnesis = Anamnesis.new(beneficiary: @beneficiary, professional: current_user)
      authorize @anamnesis, policy_class: Admin::AnamnesisPolicy
    end

    def edit
      authorize @anamnesis, policy_class: Admin::AnamnesisPolicy
    end

    def create
      @beneficiary = Beneficiary.find(params[:beneficiary_id]) if params[:beneficiary_id].present?
      @anamnesis = Anamnesis.new(anamnesis_params)
      @anamnesis.beneficiary = @beneficiary if @beneficiary
      @anamnesis.professional = current_user
      @anamnesis.created_by_professional = current_user
      authorize @anamnesis, policy_class: Admin::AnamnesisPolicy

      if @anamnesis.save
        if @anamnesis.beneficiary.present?
          redirect_to [:admin, @anamnesis.beneficiary, @anamnesis], notice: 'Anamnese criada com sucesso.'
        else
          redirect_to admin_anamneses_today_path, notice: 'Anamnese criada com sucesso.'
        end
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      authorize @anamnesis, policy_class: Admin::AnamnesisPolicy
      @anamnesis.updated_by_professional = current_user

      if @anamnesis.update(anamnesis_params)
        if @anamnesis.beneficiary.present?
          redirect_to [:admin, @anamnesis.beneficiary, @anamnesis], notice: 'Anamnese atualizada com sucesso.'
        else
          redirect_to today_admin_anamneses_path, notice: 'Anamnese atualizada com sucesso.'
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def start
      authorize @anamnesis, policy_class: Admin::AnamnesisPolicy

      if @anamnesis.iniciar!(current_user)
        redirect_to edit_admin_anamnese_path(@anamnesis), notice: 'Atendimento iniciado! Preencha os dados da anamnese.'
      else
        redirect_to today_admin_anamneses_path, alert: 'Não foi possível iniciar o atendimento.'
      end
    end

    def complete
      authorize @anamnesis, policy_class: Admin::AnamnesisPolicy

      if @anamnesis.concluir!(current_user)
        if @anamnesis.beneficiary.present?
          redirect_to [:admin, @anamnesis.beneficiary, @anamnesis], notice: 'Anamnese concluída com sucesso!'
        else
          redirect_to [:admin, @anamnesis], notice: 'Anamnese concluída com sucesso!'
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def today
      authorize Anamnesis, policy_class: Admin::AnamnesisPolicy

      @anamneses = Anamnesis.today
                            .includes(:beneficiary, :professional)
                            .order(:performed_at)

      unless current_user.permit?('anamneses.view_all')
        @anamneses = @anamneses.by_professional(current_user.professional)
      end

      respond_to do |format|
        format.html
        format.json { render json: { results: @anamneses } }
      end
    end

    def by_professional
      authorize Anamnesis, policy_class: Admin::AnamnesisPolicy

      professional = User.find(params[:professional_id])
      @anamneses = Anamnesis.by_professional(professional)
                            .includes(:beneficiary, :professional)
                            .recent

      respond_to do |format|
        format.html
        format.json { render json: { results: @anamneses } }
      end
    end

    def mark_attended
      authorize @anamnesis, policy_class: Admin::AnamnesisPolicy

      if @anamnesis.marcar_como_compareceu!(current_user)
        redirect_to today_admin_anamneses_path, notice: 'Comparecimento registrado com sucesso!'
      else
        redirect_to today_admin_anamneses_path, alert: 'Não foi possível registrar o comparecimento.'
      end
    end

    def mark_no_show
      authorize @anamnesis, policy_class: Admin::AnamnesisPolicy

      reason = params[:reason]
      if @anamnesis.marcar_como_nao_compareceu!(current_user, reason)
        redirect_to today_admin_anamneses_path,
                    notice: 'Falta registrada. Escolha reagendar ou cancelar.',
                    flash: { show_reschedule_options: @anamnesis.id }
      else
        redirect_to today_admin_anamneses_path, alert: 'Não foi possível registrar a falta.'
      end
    end

    def cancel_anamnesis
      authorize @anamnesis, policy_class: Admin::AnamnesisPolicy

      reason = params[:reason]
      if reason.blank?
        redirect_to today_admin_anamneses_path, alert: 'É necessário informar o motivo do cancelamento.'
        return
      end

      if @anamnesis.cancelar!(current_user, reason)
        redirect_to today_admin_anamneses_path, notice: 'Anamnese cancelada com sucesso!'
      else
        redirect_to today_admin_anamneses_path, alert: 'Não foi possível cancelar a anamnese.'
      end
    end

    def reschedule_form
      @anamnesis = Anamnesis.find(params[:id])
      authorize @anamnesis, policy_class: Admin::AnamnesisPolicy
    end

    def reschedule
      @anamnesis = Anamnesis.find(params[:id])
      authorize @anamnesis, policy_class: Admin::AnamnesisPolicy

      new_datetime = params[:new_datetime]
      if new_datetime.blank?
        redirect_to today_admin_anamneses_path, alert: 'É necessário informar a nova data e hora.'
        return
      end

      if @anamnesis.reagendar!(current_user, new_datetime)
        redirect_to today_admin_anamneses_path, notice: 'Anamnese reagendada com sucesso!'
      else
        redirect_to today_admin_anamneses_path, alert: 'Não foi possível reagendar a anamnese.'
      end
    end

    def print_pdf
      authorize @anamnesis, policy_class: Admin::AnamnesisPolicy

      pdf = AnamnesisPdfService.new(@anamnesis).generate
      filename = "anamnese_#{@anamnesis.beneficiary_name.parameterize}_#{@anamnesis.performed_at.strftime('%Y%m%d')}.pdf"

      send_data pdf.render,
                filename: filename,
                type: 'application/pdf',
                disposition: 'inline'
    end

    private

    def set_anamnesis
      @anamnesis = Anamnesis.find(params[:id])
    end

    def convert_date_params
      return if params[:anamnesis].blank?

      date_fields = %i[father_birth_date mother_birth_date responsible_birth_date]

      date_fields.each do |field|
        next if params[:anamnesis][field].blank?

        date_string = params[:anamnesis][field]
        next unless date_string.match?(%r{\d{2}/\d{2}/\d{4}})

        begin
          day, month, year = date_string.split('/')
          params[:anamnesis][field] = "#{year}-#{month}-#{day}"
        rescue StandardError => e
          Rails.logger.error "Erro ao converter data #{field}: #{e.message}"
        end
      end
    end

    def perform_local_search
      scope = Anamnesis.includes(:beneficiary, :professional, :portal_intake)

      scope = scope.by_professional(current_user.professional) unless current_user.permit?('anamneses.view_all')

      unless params[:include_concluidas] == 'true' || params[:status] == 'concluida'
        scope = scope.where.not(status: 'concluida')
      end

      scope = apply_filters(scope)
      scope.by_date
    end

    def build_search_filters
      filters = {}

      filters[:status] = params[:status] if params[:status].present?
      filters[:professional_id] = params[:professional_id] if params[:professional_id].present?
      filters[:referral_reason] = params[:referral_reason] if params[:referral_reason].present?
      filters[:treatment_location] = params[:treatment_location] if params[:treatment_location].present?

      if params[:period].present?
        case params[:period]
        when 'today'
          filters[:performed_at] = Date.current.to_s
        when 'this_week'
          filters[:performed_at] = "#{Date.current.beginning_of_week}..#{Date.current.end_of_week}"
        when 'this_month'
          filters[:performed_at] = "#{Date.current.beginning_of_month}..#{Date.current.end_of_month}"
        when 'last_7_days'
          filters[:performed_at] = "#{7.days.ago.to_date}..#{Date.current}"
        when 'last_30_days'
          filters[:performed_at] = "#{30.days.ago.to_date}..#{Date.current}"
        end
      end

      if params[:start_date].present? && params[:end_date].present?
        filters[:performed_at] = "#{params[:start_date]}..#{params[:end_date]}"
      end

      filters[:status] = %w[pendente em_andamento] unless params[:include_concluidas] == 'true'

      filters
    end

    def build_search_options
      {
        limit: 1000,
        sort: [build_sort_param]
      }
    end

    def build_sort_param
      order_by = params[:order_by] || 'data_realizada'
      direction = params[:direction] || 'desc'

      case order_by
      when 'beneficiary_name'
        "beneficiary_name:#{direction}"
      when 'professional_name'
        "professional_name:#{direction}"
      when 'data_realizada'
        "data_realizada:#{direction}"
      when 'status'
        "status:#{direction}"
      when 'created_at'
        "created_at:#{direction}"
      else
        'data_realizada:desc'
      end
    end

    def apply_filters(scope)
      scope = scope.by_status(params[:status]) if params[:status].present?
      scope = scope.by_professional(User.find(params[:professional_id])) if params[:professional_id].present?
      scope = scope.by_beneficiary(Beneficiary.find(params[:beneficiary_id])) if params[:beneficiary_id].present?

      scope = scope.where(referral_reason: params[:referral_reason]) if params[:referral_reason].present?

      scope = scope.where(treatment_location: params[:treatment_location]) if params[:treatment_location].present?

      scope = apply_period_filter(scope)

      if params[:start_date].present? && params[:end_date].present?
        begin
          start_date = Date.parse(params[:start_date])
          end_date = Date.parse(params[:end_date])
          scope = scope.by_date_range(start_date, end_date)
        rescue Date::Error
          Rails.logger.debug 'Data inválida nos parâmetros de filtro'
        end
      end

      scope
    end

    def apply_period_filter(scope)
      case params[:period]
      when 'today'
        scope.today
      when 'this_week'
        scope.this_week
      when 'this_month'
        scope.this_month
      when 'last_7_days'
        scope.where(performed_at: 7.days.ago..Time.current)
      when 'last_30_days'
        scope.where(performed_at: 30.days.ago..Time.current)
      else
        scope
      end
    end

    def anamnesis_params
      params.expect(
        anamnesis: [
          :performed_at, :start_time, :session_email,
          :birthplace, :birth_state, :religion,
          :father_name, :father_birth_date, :father_education, :father_profession, :father_cpf, :father_workplace,
          :mother_name, :mother_birth_date, :mother_education, :mother_profession, :mother_cpf, :mother_workplace,
          :responsible_name, :responsible_birth_date, :responsible_education, :responsible_profession,
          :attends_school, :school_name, :school_period, :school_phone, :school_enrollment_age,
          :has_support_teacher, :after_school_activities, :school_difficulties, :family_school_expectations,
          :referral_reason, :injunction, :treatment_location, :referral_hours,
          :diagnosis_completed, :responsible_doctor,
          :previous_treatment, :continue_external_treatment,
          :beneficiary_id, :portal_intake_id, :professional_id,
          :main_complaint, :complaint_noticed_since,
          :pregnancy_planned, :prenatal_care, :mother_age_at_birth,
          :had_miscarriages, :miscarriages_count, :miscarriages_type,
          :pregnancy_trauma, :pregnancy_illness, :pregnancy_illness_description,
          :pregnancy_medication, :pregnancy_medication_description,
          :pregnancy_drugs, :pregnancy_drugs_description,
          :pregnancy_alcohol, :pregnancy_smoking, :cigarettes_per_day,
          :birth_type, :birth_location_type, :birth_term,
          :had_anesthesia, :anesthesia_type, :baby_position,
          :cried_at_birth, :cord_around_neck, :cyanotic, :apgar_1min, :apgar_5min,
          :mother_hospital_days, :baby_hospital_days,
          :birth_weight, :birth_height,
          :needed_incubator, :needed_icu, :icu_reason, :birth_complications,
          :baby_health, :respiratory_problems, :general_behavior_baby,
          :breastfed, :breastfed_until, :bottle_fed, :bottle_fed_until,
          :feeding_contact, :daily_meals, :favorite_foods, :rejected_foods,
          :frequent_vomiting, :meal_behavior, :fixed_meal_schedule,
          :eats_alone, :chewing_difficulty, :drools, :drools_when, :feeding_notes,
          :held_head, :held_head_age, :rolled_over, :rolled_bilateral, :rolled_notes,
          :sat_unsupported, :sat_unsupported_age, :crawled, :crawled_age, :crawled_how,
          :stood_age, :walked_age, :climbed_stairs, :climbed_stairs_age,
          :squatted, :squatted_age, :used_walker, :used_walker_age,
          :motor_coordination_problem, :motor_coordination_description, :object_manipulation_difficulty,
          :bladder_control_day, :bladder_control_night, :bowel_control_day, :bowel_control_night,
          :babbled, :babbled_age, :speech_started_age,
          :understandable_speech, :understandable_since,
          :speech_difficulties, :speech_difficulties_description,
          :echolalia, :hearing_problems, :hearing_problems_description,
          :responds_from_distance, :easily_startled,
          :uses_gestures, :gestures_description, :uses_other_as_tool,
          :words_in_context, :shares_interests,
          :stopped_speaking, :stopped_speaking_when,
          :understands_speech, :communicates_desires,
          :reaction_not_understood, :family_reaction_communication,
          :sleep_routine, :sleep_routine_description,
          :individual_bed, :individual_bed_description,
          :sleep_quality, :nocturnal_enuresis,
          :preferred_play, :how_plays, :protective_reaction_play, :favorite_toys,
          :watches_tv, :watches_tv_how, :favorite_programs, :watches_repeatedly,
          :plays_with_others, :plays_with_others_how, :fights_with_peers,
          :defends_from_aggression, :defense_method,
          :reaction_prohibitions, :behavior_with_strangers,
          :danger_awareness, :danger_awareness_description, :new_situations_reaction,
          :obeys_orders, :shows_affection,
          :aggressive_behavior, :aggressive_behavior_description, :family_crisis_reaction,
          :previous_illnesses, :hospitalizations, :hospitalization_causes,
          :has_epilepsy, :epilepsy_frequency, :current_medications,
          :exams_done, :exams_to_do, :has_allergies, :allergies_description,
          :psychiatric_hospitalization, :psychiatric_hospitalization_who,
          :general_information,
          { specialties: {},
            previous_treatments: [],
            external_treatments: [],
            preferred_schedule: [],
            unavailable_schedule: [],
            family_composition: [],
            family_conditions: [] }
        ]
      )
    end

    def professionals
      @professionals = if current_user.permit?('anamneses.view_all')
                         User.professionals.order(:full_name)
                       else
                         [current_user.professional].compact
                       end

      render json: {
        professionals: @professionals.map { |p| { id: p.id, name: p.full_name } }
      }
    end
  end
end
