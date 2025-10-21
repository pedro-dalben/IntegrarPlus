# frozen_string_literal: true

module Admin
  class AnamnesesController < BaseController
    before_action :set_anamnesis, only: %i[show edit update complete]

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
        redirect_to admin_anamnesis_path(@anamnesis), notice: 'Anamnese criada com sucesso.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      authorize @anamnesis, policy_class: Admin::AnamnesisPolicy
      @anamnesis.updated_by_professional = current_user

      if @anamnesis.update(anamnesis_params)
        redirect_to admin_anamnesis_path(@anamnesis), notice: 'Anamnese atualizada com sucesso.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def complete
      authorize @anamnesis, policy_class: Admin::AnamnesisPolicy

      if @anamnesis.concluir!(current_user)
        redirect_to admin_anamnesis_path(@anamnesis), notice: 'Anamnese concluída com sucesso!'
      else
        redirect_to admin_anamnesis_path(@anamnesis), alert: 'Não foi possível concluir a anamnese.'
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

    private

    def set_anamnesis
      @anamnesis = Anamnesis.find(params[:id])
    end

    def perform_local_search
      scope = Anamnesis.includes(:beneficiary, :professional, :portal_intake)

      # Filtrar por profissional se não tiver permissão para ver todas
      scope = scope.by_professional(current_user.professional) unless current_user.permit?('anamneses.view_all')

      # Por padrão, não mostrar anamneses concluídas a menos que seja especificado
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

      # Aplicar filtro de período para busca
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

      # Filtro por data personalizada
      if params[:start_date].present? && params[:end_date].present?
        filters[:performed_at] = "#{params[:start_date]}..#{params[:end_date]}"
      end

      # Por padrão, não incluir concluídas na busca
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

      # Filtro por motivo de encaminhamento
      scope = scope.where(referral_reason: params[:referral_reason]) if params[:referral_reason].present?

      # Filtro por local de tratamento
      scope = scope.where(treatment_location: params[:treatment_location]) if params[:treatment_location].present?

      # Aplicar filtro de período
      scope = apply_period_filter(scope)

      # Filtro por período personalizado (data inicial e final)
      if params[:start_date].present? && params[:end_date].present?
        begin
          start_date = Date.parse(params[:start_date])
          end_date = Date.parse(params[:end_date])
          scope = scope.by_date_range(start_date, end_date)
        rescue Date::Error
          # Ignora filtro de data se inválido
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
        anamnesis: %i[
          performed_at
          father_name father_birth_date father_education father_profession
          mother_name mother_birth_date mother_education mother_profession
          responsible_name responsible_birth_date responsible_education responsible_profession
          attends_school school_name school_period
          referral_reason injunction treatment_location referral_hours
          specialties diagnosis_completed responsible_doctor
          previous_treatment previous_treatments continue_external_treatment external_treatments
          preferred_schedule unavailable_schedule
          beneficiary_id portal_intake_id
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
