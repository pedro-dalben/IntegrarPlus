# frozen_string_literal: true

module Admin
  class PortalIntakesController < BaseController
    before_action :set_portal_intake,
                  only: %i[show update schedule_anamnesis reschedule_anamnesis cancel_anamnesis agenda_view]

    def index
      @portal_intakes = policy_scope(PortalIntake, policy_scope_class: Admin::PortalIntakePolicy::Scope)
                        .includes(:operator, :journey_events)
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
          professional_user = User.find(professional_id)
          professional = professional_user.professional

          Rails.logger.debug { "👤 User: #{professional_user.inspect}" }
          Rails.logger.debug { "👤 Professional: #{professional.inspect}" }
          Rails.logger.debug { "👤 Agenda: #{agenda.name}" }

          if professional.nil?
            Rails.logger.error { "❌ Professional é nil para User ID: #{professional_id}" }
            flash.now[:alert] = 'Profissional não encontrado.'
            render :schedule_anamnesis
            return
          end

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
          professional_user = User.find(professional_id)
          professional = professional_user.professional

          Rails.logger.debug { "👤 User: #{professional_user.inspect}" }
          Rails.logger.debug { "👤 Professional: #{professional.inspect}" }
          Rails.logger.debug { "👤 Agenda: #{agenda.name}" }

          if professional.nil?
            Rails.logger.error { "❌ Professional é nil para User ID: #{professional_id}" }
            flash.now[:alert] = 'Profissional não encontrado.'
            render :reschedule_anamnesis
            return
          end

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
        professional_user = User.find(params[:professional_id])
        @selected_professional = professional_user.professional
      end

      # Buscar agendamentos existentes para esta agenda e profissional
      @existing_appointments = get_existing_appointments(@agenda, @selected_professional)
    end

    private

    def set_portal_intake
      @portal_intake = PortalIntake.find(params[:id])
    end

    def get_existing_appointments(agenda, professional = nil)
      query = MedicalAppointment.where(agenda: agenda)
                                .where(scheduled_at: Date.current.all_week)
                                .includes(:professional, :patient)

      # professional é um objeto Professional, não User
      query = query.where(professional: professional) if professional.present?

      query
    end

    helper_method :generate_time_slots, :is_slot_available?, :is_working_hour?, :is_past_slot?

    def is_past_slot?(datetime)
      datetime < Time.current
    end

    def generate_time_slots
      # Gerar slots baseado na configuração da agenda
      slots = []
      start_time = 8 # 08:00
      end_time = 17 # 17:00
      duration = @agenda&.slot_duration_minutes || 50
      buffer = @agenda&.buffer_minutes || 10

      current_time = start_time * 60 # Converter para minutos
      end_time_minutes = end_time * 60

      while current_time < end_time_minutes
        start_hour = current_time / 60
        start_min = current_time % 60
        end_time_slot = current_time + duration

        end_hour = end_time_slot / 60
        end_min = end_time_slot % 60

        slots << "#{start_hour.to_s.rjust(2,
                                          '0')}:#{start_min.to_s.rjust(2,
                                                                       '0')} - #{end_hour.to_s.rjust(2,
                                                                                                     '0')}:#{end_min.to_s.rjust(
                                                                                                       2, '0'
                                                                                                     )}"

        current_time += duration + buffer
      end

      slots
    end

    def is_slot_available?(datetime, professional = nil)
      return false if is_past_slot?(datetime)

      query = MedicalAppointment.where(scheduled_at: datetime)

      query = query.where(professional: professional) if professional.present?

      if @agenda.present?
        duration_minutes = @agenda.slot_duration_minutes + @agenda.buffer_minutes
        start_time = datetime
        end_time = datetime + duration_minutes.minutes

        conflict_query = MedicalAppointment.where(scheduled_at: start_time...end_time)

        conflict_query = conflict_query.where(professional: professional) if professional.present?

        return !conflict_query.exists?
      end

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
