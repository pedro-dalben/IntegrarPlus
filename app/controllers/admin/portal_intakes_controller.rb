# frozen_string_literal: true

module Admin
  class PortalIntakesController < BaseController
    before_action :set_portal_intake, only: %i[show update schedule_anamnesis agenda_view]

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

      return unless request.post?

      agenda_id = params[:agenda_id]
      professional_id = params[:professional_id]
      scheduled_date = params[:scheduled_date]
      scheduled_time = params[:scheduled_time]

      if agenda_id.present? && professional_id.present? && scheduled_date.present? && scheduled_time.present?
        begin
          scheduled_datetime = DateTime.parse("#{scheduled_date} #{scheduled_time}")
          agenda = Agenda.find(agenda_id)
          professional = User.find(professional_id)

          # Verificar se o horário está disponível usando o service
          scheduling_service = AppointmentSchedulingService.new(professional, agenda)
          availability_check = scheduling_service.check_availability(scheduled_datetime, agenda.slot_duration_minutes)

          unless availability_check[:available]
            flash.now[:alert] = 'Este horário já está ocupado. Por favor, selecione outro horário.'
            render :schedule_anamnesis
            return
          end

          # Criar o agendamento no PortalIntake
          @portal_intake.schedule_anamnesis!(scheduled_datetime, current_user)

          # Usar o service de agendamento para criar evento e appointment
          scheduling_service = AppointmentSchedulingService.new(professional, agenda)

          appointment_data = {
            scheduled_datetime: scheduled_datetime,
            appointment_type: 'initial_consultation',
            priority: 'normal',
            notes: "Anamnese para #{@portal_intake.beneficiary_name} - #{@portal_intake.plan_name}",
            title: "Anamnese - #{@portal_intake.beneficiary_name}",
            description: "Anamnese para #{@portal_intake.plan_name}",
            created_by: current_user,
            source_context: {
              type: 'portal_intake',
              id: @portal_intake.id
            }
          }

          result = scheduling_service.schedule_appointment(appointment_data)

          unless result[:success]
            flash.now[:alert] = "Erro ao agendar: #{result[:error]}"
            render :schedule_anamnesis
            return
          end

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
      @selected_professional = @agenda.professionals.find(params[:professional_id]) if params[:professional_id].present?

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

      query = query.where(professional: professional) if professional.present?

      query
    end

    helper_method :generate_time_slots, :is_slot_available?, :is_working_hour?

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
      # Verificar se já existe um agendamento neste horário
      query = MedicalAppointment.where(scheduled_at: datetime)

      # Se um profissional específico foi selecionado, verificar apenas para ele
      query = query.where(professional: professional) if professional.present?

      # Verificar se há conflitos de horário (considerando duração + buffer)
      if @agenda.present?
        duration_minutes = @agenda.slot_duration_minutes + @agenda.buffer_minutes
        start_time = datetime
        end_time = datetime + duration_minutes.minutes

        conflict_query = MedicalAppointment.where(
          scheduled_at: start_time..end_time
        )

        conflict_query = conflict_query.where(professional: professional) if professional.present?

        return !conflict_query.exists?
      end

      !query.exists?
    end

    def is_working_hour?(date, time_slot)
      # Verificar se é um horário de funcionamento da agenda
      # Por enquanto, consideramos segunda a sexta, 08:00 às 17:00
      return false if date.saturday? || date.sunday?

      hour = time_slot.split(' - ').first.split(':').first.to_i
      hour >= 8 && hour < 17
    end

    def portal_intake_params
      params.expect(
        portal_intake: %i[
          beneficiary_name plan_name card_code
          convenio carteira_codigo nome telefone_responsavel
          data_encaminhamento data_nascimento endereco responsavel
          tipo_convenio cpf
        ]
      )
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
