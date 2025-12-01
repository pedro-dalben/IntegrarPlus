# frozen_string_literal: true

module Admin
  class PortalIntakesController < BaseController
    before_action :set_portal_intake,
                  only: %i[show update schedule_anamnesis reschedule_anamnesis cancel_anamnesis agenda_view
                           check_slot_availability]

    def index
      @portal_intakes = policy_scope(PortalIntake, policy_scope_class: Admin::PortalIntakePolicy::Scope)
                        .includes(:operator)
                        .recent

      @portal_intakes = apply_filters(@portal_intakes)
      @pagy, @portal_intakes = pagy(@portal_intakes, items: 20)

      @operators = ExternalUser.active.order(:company_name)
      @statuses = PortalIntake.statuses.keys

      respond_to do |format|
        format.html
        format.json { render json: { results: @portal_intakes, count: @pagy.count } }
      end
    end

    def show
      authorize @portal_intake, policy_class: Admin::PortalIntakePolicy
      @journey_events = @portal_intake.journey_events.recent
    end

    def new
      authorize PortalIntake, policy_class: Admin::PortalIntakePolicy
      @portal_intake = PortalIntake.new
      @portal_intake.data_encaminhamento = Date.current
      @portal_intake.portal_intake_referrals.build
      @operators = ExternalUser.active.order(:company_name)
    end

    def create
      authorize PortalIntake, policy_class: Admin::PortalIntakePolicy

      @portal_intake = PortalIntake.new(portal_intake_params)
      @operators = ExternalUser.active.order(:company_name)

      Rails.logger.info("[Admin::PortalIntakes#create] referrals_params=#{params.dig(:portal_intake,
                                                                                     :portal_intake_referrals_attributes).inspect}")
      Rails.logger.info("[Admin::PortalIntakes#create] nested size before save=#{@portal_intake.portal_intake_referrals.size}")

      selected_operator = ExternalUser.find_by(id: params[:portal_intake][:operator_id])
      if selected_operator.nil?
        flash.now[:alert] = 'Operadora é obrigatória.'
        render :new, status: :unprocessable_entity
        return
      end

      @portal_intake.operator = selected_operator
      @portal_intake.requested_at = Time.current
      @portal_intake.data_encaminhamento = Date.current
      @portal_intake.convenio = selected_operator.company_name
      @portal_intake.plan_name = selected_operator.company_name
      @portal_intake.beneficiary_name = @portal_intake.nome

      if @portal_intake.save
        redirect_to admin_portal_intake_path(@portal_intake), notice: 'Entrada criada com sucesso.'
      else
        Rails.logger.warn("[Admin::PortalIntakes#create] save_failed errors=#{@portal_intake.errors.full_messages}")
        render :new, status: :unprocessable_entity
      end
    end

    def update
      authorize @portal_intake, policy_class: Admin::PortalIntakePolicy

      if @portal_intake.update(portal_intake_params)
        redirect_to admin_portal_intake_path(@portal_intake),
                    notice: 'Entrada atualizada com sucesso.'
      else
        render :show, status: :unprocessable_entity
      end
    end

    def schedule_anamnesis
      authorize @portal_intake, policy_class: Admin::PortalIntakePolicy

      # Buscar agendas de anamnese ativas
      @anamnesis_agendas = Agenda.active.by_service_type(:anamnese).includes(:professionals)

      Rails.logger.debug { "🔍 schedule_anamnesis: request.post? = #{request.post?}, format = #{request.format}" }

      return unless request.post?

      agenda_id = params[:agenda_id]
      professional_id = params[:professional_id]
      scheduled_date = params[:scheduled_date]
      scheduled_time = params[:scheduled_time]

      Rails.logger.debug '🔍 Parâmetros recebidos:'
      Rails.logger.debug { "  agenda_id: #{agenda_id.inspect} (present? #{agenda_id.present?})" }
      Rails.logger.debug { "  professional_id: #{professional_id.inspect} (present? #{professional_id.present?})" }
      Rails.logger.debug { "  scheduled_date: #{scheduled_date.inspect} (present? #{scheduled_date.present?})" }
      Rails.logger.debug { "  scheduled_time: #{scheduled_time.inspect} (present? #{scheduled_time.present?})" }
      Rails.logger.debug { "  Todos os params: #{params.inspect}" }

      if agenda_id.present? && professional_id.present? && scheduled_date.present? && scheduled_time.present?
        begin
          Rails.logger.debug do
            "📅 Iniciando agendamento: agenda_id=#{agenda_id}, professional_id=#{professional_id}, date=#{scheduled_date}, time=#{scheduled_time}"
          end

          scheduled_datetime = Time.zone.parse("#{scheduled_date} #{scheduled_time}")

          if scheduled_datetime < Time.current
            flash.now[:alert] = 'Não é possível agendar para um horário que já passou.'
            render :schedule_anamnesis
            return
          end

          agenda = Agenda.find(agenda_id)
          professional, professional_user = resolve_professional(professional_id)

          if professional.nil? || professional_user.nil?
            Rails.logger.error { "❌ Profissional inválido para ID: #{professional_id}" }
            flash.now[:alert] = 'Profissional não encontrado.'
            render :schedule_anamnesis
            return
          end

          Rails.logger.debug { "👤 User: #{professional_user.inspect}" }
          Rails.logger.debug { "👤 Professional: #{professional.inspect}" }
          Rails.logger.debug { "👤 Agenda: #{agenda.name}" }

          # Verificar se o horário está disponível usando o service
          scheduling_service = AppointmentSchedulingService.new(professional, agenda)
          availability_check = scheduling_service.check_availability(scheduled_datetime, agenda.slot_duration_minutes)

          unless availability_check[:available]
            flash.now[:alert] = 'Este horário já está ocupado. Por favor, selecione outro horário.'
            render :schedule_anamnesis
            return
          end

          # Criar o agendamento no PortalIntake
          # current_user é um User, mas o método schedule_anamnesis! espera um admin_user (User)
          @portal_intake.schedule_anamnesis!(scheduled_datetime, current_user)

          # Criar a Anamnesis
          anamnesis = Anamnesis.new(
            portal_intake: @portal_intake,
            professional: professional_user,
            performed_at: scheduled_datetime,
            status: 'pendente',
            referral_reason: 'aba',
            treatment_location: 'clinica',
            referral_hours: 20,
            created_by_professional: current_user
          )

          begin
            anamnesis.save!
          rescue ActiveRecord::RecordInvalid => e
            Rails.logger.error "❌ Erro ao criar anamnese: #{e.message}"
            flash.now[:alert] = "Erro ao criar anamnese: #{e.message}"
            render :schedule_anamnesis
            return
          rescue StandardError => e
            Rails.logger.error "❌ Erro inesperado ao criar anamnese: #{e.class} - #{e.message}"
            Rails.logger.error e.backtrace.join("\n")
            flash.now[:alert] = "Erro ao criar anamnese: #{e.message}"
            render :schedule_anamnesis
            return
          end

          # Usar o service de agendamento para criar evento e appointment
          scheduling_service = AppointmentSchedulingService.new(professional, agenda)

          appointment_data = {
            scheduled_datetime: scheduled_datetime,
            appointment_type: 'initial_consultation',
            priority: 'normal',
            notes: "Anamnese para #{@portal_intake.beneficiary_name} - #{@portal_intake.plan_name}",
            title: "Anamnese - #{@portal_intake.beneficiary_name}",
            description: "Anamnese para #{@portal_intake.plan_name}",
            created_by: professional,
            patient: nil,
            source_context: {
              type: 'portal_intake',
              id: @portal_intake.id
            }
          }

          Rails.logger.debug { "📋 Dados do agendamento: #{appointment_data}" }

          result = scheduling_service.schedule_appointment(appointment_data)

          Rails.logger.debug { "📋 Resultado do agendamento: #{result}" }

          unless result[:success]
            Rails.logger.error "❌ Erro no agendamento: #{result[:error]}"
            flash.now[:alert] = "Erro ao agendar: #{result[:error]}"
            render :schedule_anamnesis
            return
          end

          medical_appointment = result[:medical_appointment]
          medical_appointment&.update(anamnesis: anamnesis)

          Rails.logger.debug '✅ Agendamento criado com sucesso, redirecionando...'
          redirect_to admin_portal_intake_path(@portal_intake),
                      notice: 'Anamnese agendada com sucesso!'
        rescue StandardError => e
          flash.now[:alert] = "Erro ao agendar: #{e.message}"
          render :schedule_anamnesis
        end
      else
        flash.now[:alert] = 'Todos os campos são obrigatórios.'
        render :schedule_anamnesis
      end

      # Para requisições GET, apenas renderizar a view de agendamento
      # A lógica de POST já foi tratada acima
    end

    def reschedule_anamnesis
      authorize @portal_intake, policy_class: Admin::PortalIntakePolicy

      unless @portal_intake.can_reschedule_anamnesis?
        redirect_to admin_portal_intake_path(@portal_intake),
                    alert: 'Não é possível reagendar esta anamnese.'
        return
      end

      # Buscar agendas de anamnese ativas
      @anamnesis_agendas = Agenda.active.by_service_type(:anamnese).includes(:professionals)

      Rails.logger.debug { "🔍 reschedule_anamnesis: request.patch? = #{request.patch?}, format = #{request.format}" }

      return unless request.patch?

      agenda_id = params[:agenda_id]
      professional_id = params[:professional_id]
      scheduled_date = params[:scheduled_date]
      scheduled_time = params[:scheduled_time]
      reason = params[:reason]

      if agenda_id.present? && professional_id.present? && scheduled_date.present? && scheduled_time.present?
        begin
          Rails.logger.debug do
            "📅 Iniciando reagendamento: agenda_id=#{agenda_id}, professional_id=#{professional_id}, date=#{scheduled_date}, time=#{scheduled_time}"
          end

          scheduled_datetime = Time.zone.parse("#{scheduled_date} #{scheduled_time}")
          agenda = Agenda.find(agenda_id)
          professional, professional_user = resolve_professional(professional_id)

          if professional.nil? || professional_user.nil?
            Rails.logger.error { "❌ Profissional inválido para ID: #{professional_id}" }
            flash.now[:alert] = 'Profissional não encontrado.'
            render :reschedule_anamnesis
            return
          end

          Rails.logger.debug { "👤 User: #{professional_user.inspect}" }
          Rails.logger.debug { "👤 Professional: #{professional.inspect}" }
          Rails.logger.debug { "👤 Agenda: #{agenda.name}" }

          # Verificar se o horário está disponível usando o service
          scheduling_service = AppointmentSchedulingService.new(professional, agenda)
          availability_check = scheduling_service.check_availability(scheduled_datetime, agenda.slot_duration_minutes)

          unless availability_check[:available]
            flash.now[:alert] = 'Este horário já está ocupado. Por favor, selecione outro horário.'
            render :reschedule_anamnesis
            return
          end

          # Reagendar a anamnese
          if @portal_intake.reschedule_anamnesis!(scheduled_datetime, current_user, reason)
            # Atualizar a anamnese associada se existir
            if @portal_intake.anamnesis.present?
              @portal_intake.anamnesis.update!(
                performed_at: scheduled_datetime,
                professional: professional_user
              )

              # Criar novo MedicalAppointment para o novo horário
              scheduling_service = AppointmentSchedulingService.new(professional, agenda)

              appointment_data = {
                scheduled_datetime: scheduled_datetime,
                appointment_type: 'initial_consultation',
                priority: 'normal',
                notes: "Anamnese reagendada para #{@portal_intake.beneficiary_name} - #{@portal_intake.plan_name}",
                title: "Anamnese - #{@portal_intake.beneficiary_name}",
                description: "Anamnese para #{@portal_intake.plan_name}",
                created_by: professional,
                patient: nil,
                source_context: {
                  type: 'portal_intake',
                  id: @portal_intake.id
                }
              }

              result = scheduling_service.schedule_appointment(appointment_data)

              if result[:success]
                medical_appointment = result[:medical_appointment]
                medical_appointment&.update(anamnesis: @portal_intake.anamnesis)
              end
            end

            Rails.logger.debug '✅ Reagendamento realizado com sucesso, redirecionando...'
            redirect_to admin_portal_intake_path(@portal_intake),
                        notice: 'Anamnese reagendada com sucesso!'
          else
            flash.now[:alert] = 'Erro ao reagendar anamnese.'
            render :reschedule_anamnesis
          end
        rescue StandardError => e
          flash.now[:alert] = "Erro ao reagendar: #{e.message}"
          render :reschedule_anamnesis
        end
      else
        flash.now[:alert] = 'Todos os campos são obrigatórios.'
        render :reschedule_anamnesis
      end

      # Para requisições GET, apenas renderizar a view de reagendamento
      # A lógica de PATCH já foi tratada acima
    end

    def cancel_anamnesis
      authorize @portal_intake, policy_class: Admin::PortalIntakePolicy

      unless @portal_intake.can_cancel_anamnesis?
        redirect_to admin_portal_intake_path(@portal_intake),
                    alert: 'Não é possível cancelar esta anamnese.'
        return
      end

      reason = params[:reason]

      if @portal_intake.cancel_anamnesis!(current_user, reason)
        redirect_to admin_portal_intake_path(@portal_intake),
                    notice: 'Anamnese cancelada com sucesso. Status retornado para aguardando agendamento.'
      else
        redirect_to admin_portal_intake_path(@portal_intake),
                    alert: 'Erro ao cancelar anamnese.'
      end
    end

    def agenda_view
      agenda_id = params[:agenda_id]
      @agenda = Agenda.find(agenda_id) if agenda_id.present?

      if @agenda.nil?
        redirect_to schedule_anamnesis_admin_portal_intake_path(@portal_intake),
                    alert: 'Agenda não encontrada.'
        return
      end

      # Buscar profissional selecionado (se houver)
      @selected_professional = nil
      if params[:professional_id].present?
        professional, professional_user = resolve_professional(params[:professional_id])
        @selected_professional = professional
        @selected_professional_user = professional_user
      end

      # Determinar semana a ser exibida
      if params[:week_start].present?
        begin
          @week_start = Date.parse(params[:week_start])
        rescue ArgumentError
          @week_start = Date.current.beginning_of_week
        end
      else
        @week_start = Date.current.beginning_of_week
      end

      @week_end = @week_start.end_of_week

      # Buscar agendamentos existentes para esta agenda e profissional na semana selecionada
      @existing_appointments = get_existing_appointments(@agenda, @selected_professional, @week_start)
    end

    def check_slot_availability
      authorize @portal_intake, policy_class: Admin::PortalIntakePolicy

      agenda_id = params[:agenda_id]
      professional_id = params[:professional_id]
      scheduled_datetime = params[:scheduled_datetime]

      if agenda_id.present? && scheduled_datetime.present?
        begin
          datetime = Time.zone.parse(scheduled_datetime)
          agenda = Agenda.find(agenda_id)

          professional = nil
          if professional_id.present? && professional_id != 'all'
            professional, _professional_user = resolve_professional(professional_id)

            if professional.nil?
              render json: {
                available: false,
                error: 'Profissional não encontrado'
              }, status: :not_found
              return
            end
          end

          professional ||= agenda.professionals.first

          scheduling_service = AppointmentSchedulingService.new(professional, agenda)
          availability_check = scheduling_service.check_availability(datetime, agenda.slot_duration_minutes)

          render json: {
            available: availability_check[:available],
            conflicts: availability_check[:conflicts]&.map do |conflict|
              {
                type: conflict[:type],
                message: conflict[:type] == 'event' ? "Conflito com evento '#{conflict[:object].title}'" : 'Conflito com agendamento existente'
              }
            end || []
          }
        rescue StandardError => e
          render json: {
            available: false,
            error: e.message
          }, status: :unprocessable_entity
        end
      else
        render json: {
          available: false,
          error: 'Parâmetros inválidos'
        }, status: :bad_request
      end
    end

    private

    def set_portal_intake
      @portal_intake = PortalIntake.find(params[:id])
    end

    def resolve_professional(identifier)
      return [nil, nil] if identifier.blank? || identifier == 'all'

      professional = Professional.find_by(id: identifier)
      professional_user = professional&.user

      if professional.nil?
        professional_user = User.find_by(id: identifier)
        professional = professional_user&.professional
      end

      [professional, professional_user]
    end

    def get_existing_appointments(agenda, professional = nil, week_start = nil)
      week_start ||= Date.current.beginning_of_week
      week_range = week_start.all_week

      query = MedicalAppointment.where(agenda: agenda)
                                .where(scheduled_at: week_range)
                                .includes(:professional, :patient)

      # professional é um objeto Professional, não User
      query = query.where(professional: professional) if professional.present?

      query
    end

    helper_method :generate_time_slots, :is_slot_available?, :is_working_hour?, :is_past_slot?, :is_slot_buffered?

    def is_past_slot?(datetime)
      datetime < Time.current
    end

    def is_slot_buffered?(datetime, professional = nil)
      return false if @agenda.blank? || @agenda.buffer_minutes.zero?

      professional_record = if professional.present?
                              professional.is_a?(User) ? professional.professional : professional
                            end

      slot_start = datetime
      30.minutes

      query = MedicalAppointment.where(agenda: @agenda)
                                .where.not(status: %w[cancelled no_show])

      query = query.where(professional: professional_record) if professional_record.present?

      query.any? do |appointment|
        appointment_end = appointment.scheduled_at + appointment.duration_minutes.minutes
        buffer_end = appointment_end + @agenda.buffer_minutes.minutes

        slot_start >= appointment_end && slot_start < buffer_end
      end
    end

    def generate_time_slots
      slots = []
      slot_interval = 30

      if @agenda.present? && @agenda.working_hours.present? && @agenda.working_hours['weekdays'].present?
        all_times = []

        @agenda.working_hours['weekdays'].each do |day_config|
          next if day_config['periods'].blank?

          day_config['periods'].each do |period|
            start_str = period['start'] || period['start_time']
            end_str = period['end'] || period['end_time']

            next unless start_str.present? && end_str.present?

            begin
              start_time = Time.zone.parse(start_str)
              end_time = Time.zone.parse(end_str)

              start_minutes = (start_time.hour * 60) + start_time.min
              end_minutes = (end_time.hour * 60) + end_time.min

              all_times << start_minutes
              all_times << end_minutes
            rescue ArgumentError
              next
            end
          end
        end

        if all_times.any?
          start_time_minutes = all_times.min
          end_time_minutes = all_times.max
        else
          start_time_minutes = 8 * 60
          end_time_minutes = 17 * 60
        end
      else
        start_time_minutes = 8 * 60
        end_time_minutes = 17 * 60
      end

      current_time = start_time_minutes

      while current_time < end_time_minutes
        start_hour = current_time / 60
        start_min = current_time % 60
        end_time_slot = current_time + slot_interval

        end_hour = end_time_slot / 60
        end_min = end_time_slot % 60

        slots << "#{start_hour.to_s.rjust(2,
                                          '0')}:#{start_min.to_s.rjust(2,
                                                                       '0')} - #{end_hour.to_s.rjust(2,
                                                                                                     '0')}:#{end_min.to_s.rjust(
                                                                                                       2, '0'
                                                                                                     )}"

        current_time += slot_interval
      end

      slots.uniq
    end

    def is_slot_available?(datetime, professional = nil)
      return false if is_past_slot?(datetime)

      if @agenda.present?
        duration_minutes = @agenda.slot_duration_minutes
        start_time = datetime
        end_time = datetime + duration_minutes.minutes

        professional_record = if professional.present?
                                professional.is_a?(User) ? professional.professional : professional
                              end

        if professional_record.present?
          existing_appointments = MedicalAppointment.where(professional: professional_record)
                                                    .where(agenda: @agenda)
                                                    .where('scheduled_at < ? AND scheduled_at + interval \'1 minute\' * duration_minutes > ?', end_time, start_time)
                                                    .where.not(status: %w[cancelled no_show])

          return false if existing_appointments.exists?

          existing_events = Event.where(professional: professional_record)
                                 .where('start_time < ? AND end_time > ?', end_time, start_time)
                                 .active_events

          return false if existing_events.exists?
        else
          query = MedicalAppointment.where(agenda: @agenda)
                                    .where('scheduled_at < ? AND scheduled_at + interval \'1 minute\' * duration_minutes > ?', end_time, start_time)
                                    .where.not(status: %w[cancelled no_show])

          return !query.exists?
        end
      end

      query = MedicalAppointment.where(scheduled_at: datetime)
                                .where.not(status: %w[cancelled no_show])

      query = query.where(professional: professional) if professional.present?

      !query.exists?
    end

    def is_working_hour?(date, time_slot)
      Rails.logger.debug { "🔍 Verificando horário: #{date} - #{time_slot}" }

      if @selected_professional.present? && @agenda.present?
        professional_record = @selected_professional.is_a?(User) ? @selected_professional.professional : @selected_professional

        if professional_record.present?
          availabilities = professional_record.professional_availabilities
                                              .where(agenda: @agenda)
                                              .for_day(date.wday)
                                              .active

          unless availabilities.empty?
            slot_time = time_slot.split(' - ').first
            hour, minute = slot_time.split(':').map(&:to_i)
            slot_start_minutes = (hour * 60) + minute

            return availabilities.any? do |availability|
              availability.periods.any? do |period|
                start_time = period['start'] || period['start_time']
                end_time = period['end'] || period['end_time']
                next false unless start_time.present? && end_time.present?

                start_hour, start_min = start_time.split(':').map(&:to_i)
                end_hour, end_min = end_time.split(':').map(&:to_i)
                start_minutes = (start_hour * 60) + start_min
                end_minutes = (end_hour * 60) + end_min

                slot_start_minutes >= start_minutes && slot_start_minutes < end_minutes
              end
            end
          end
        end

        # Fallback para horários da agenda
        day_config = @agenda.working_hours['weekdays']&.find { |d| d['wday'] == date.wday }
        return false if day_config.blank? || day_config['periods'].blank?

        slot_time = time_slot.split(' - ').first
        hour, minute = slot_time.split(':').map(&:to_i)
        slot_start_minutes = (hour * 60) + minute

        day_config['periods'].any? do |period|
          start_time = period['start'] || period['start_time']
          end_time = period['end'] || period['end_time']
          next false unless start_time.present? && end_time.present?

          start_hour, start_min = start_time.split(':').map(&:to_i)
          end_hour, end_min = end_time.split(':').map(&:to_i)
          start_minutes = (start_hour * 60) + start_min
          end_minutes = (end_hour * 60) + end_min

          slot_start_minutes >= start_minutes && slot_start_minutes < end_minutes
        end
      else
        return false if date.saturday? || date.sunday?

        hour = time_slot.split(' - ').first.split(':').first.to_i
        minute = time_slot.split(' - ').first.split(':').last.to_i
        total_minutes = (hour * 60) + minute
        start_minutes = 8 * 60
        end_minutes = 17 * 60

        total_minutes >= start_minutes && total_minutes < end_minutes
      end
    end

    def portal_intake_params
      portal_params = params.expect(
        portal_intake: [:beneficiary_name, :plan_name, :card_code,
                        :convenio, :carteira_codigo, :nome, :telefone_responsavel,
                        :data_encaminhamento, :data_nascimento, :endereco, :responsavel,
                        :data_recebimento_email,
                        :tipo_convenio, :cpf, :operator_id,
                        { portal_intake_referrals_attributes: %i[
                          id cid encaminhado_para medico medico_crm data_encaminhamento descricao _destroy
                        ] }]
      )

      Rails.logger.info("[Admin::PortalIntakes#portal_intake_params] permitted=#{portal_params.to_h.inspect}")
      portal_params
    end

    def apply_filters(scope)
      scope = scope.by_operator(params[:operator_id]) if params[:operator_id].present?
      scope = scope.by_status(params[:status]) if params[:status].present?

      if params[:start_date].present? && params[:end_date].present?
        begin
          start_date = Date.parse(params[:start_date])
          end_date = Date.parse(params[:end_date])
          scope = scope.requested_between(start_date, end_date)
        rescue Date::Error
          # Ignora filtro de data se inválido
        end
      end

      scope
    end
  end
end
