# frozen_string_literal: true

module Admin
  class MedicalAppointmentsController < Admin::BaseController
    before_action :set_medical_appointment,
                  only: %i[show edit update destroy cancel reschedule complete mark_no_show]
    before_action :authorize_medical_appointment

    def index
      @medical_appointments = MedicalAppointment.includes(:agenda, :professional, :patient)
                                                .order(scheduled_at: :desc)

      if params[:professional].present?
        @medical_appointments = @medical_appointments.where(professional: params[:professional])
      end
      if params[:appointment_type].present?
        @medical_appointments = @medical_appointments.where(appointment_type: params[:appointment_type])
      end
      @medical_appointments = @medical_appointments.where(status: params[:status]) if params[:status].present?
      @medical_appointments = @medical_appointments.where(priority: params[:priority]) if params[:priority].present?

      if params[:date].present?
        date = Date.parse(params[:date])
        @medical_appointments = @medical_appointments.where(scheduled_at: date.all_day)
      end

      @professionals = User.joins(:professional).where(professionals: { active: true })
      @appointment_types = MedicalAppointment.appointment_types.keys
      @statuses = MedicalAppointment.statuses.keys
      @priorities = MedicalAppointment.priorities.keys
    end

    def show
      @appointment_notes = @medical_appointment.appointment_notes.includes(:created_by).order(created_at: :desc)
      @appointment_attachments = @medical_appointment.appointment_attachments.includes(:uploaded_by).order(created_at: :desc)
    end

    def new
      @medical_appointment = MedicalAppointment.new
      @agendas = Agenda.active.includes(:professionals)
      @professionals = User.joins(:professional).where(professionals: { active: true })
      @patients = User.joins(:professional).where(professionals: { active: true })
    end

    def edit
      @agendas = Agenda.active.includes(:professionals)
      @professionals = User.joins(:professional).where(professionals: { active: true })
      @patients = User.joins(:professional).where(professionals: { active: true })
    end

    def create
      @medical_appointment = MedicalAppointmentService.create_appointment(medical_appointment_params)

      if @medical_appointment.persisted?
        redirect_to admin_medical_appointment_path(@medical_appointment), notice: 'Consulta agendada com sucesso.'
      else
        @agendas = Agenda.active.includes(:professionals)
        @professionals = User.joins(:professional).where(professionals: { active: true })
        @patients = User.joins(:professional).where(professionals: { active: true })
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @medical_appointment = MedicalAppointmentService.update_appointment(@medical_appointment,
                                                                          medical_appointment_params)

      if @medical_appointment.errors.empty?
        redirect_to admin_medical_appointment_path(@medical_appointment), notice: 'Consulta atualizada com sucesso.'
      else
        @agendas = Agenda.active.includes(:professionals)
        @professionals = User.joins(:professional).where(professionals: { active: true })
        @patients = User.joins(:professional).where(professionals: { active: true })
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @medical_appointment.can_be_cancelled?
        @medical_appointment.destroy
        redirect_to admin_medical_appointments_path, notice: 'Consulta removida com sucesso.'
      else
        redirect_to admin_medical_appointment_path(@medical_appointment), alert: 'Não é possível remover esta consulta.'
      end
    end

    def cancel
      if @medical_appointment.can_be_cancelled?
        MedicalAppointmentService.cancel_appointment(@medical_appointment, params[:reason])
        redirect_to admin_medical_appointment_path(@medical_appointment), notice: 'Consulta cancelada com sucesso.'
      else
        redirect_to admin_medical_appointment_path(@medical_appointment),
                    alert: 'Não é possível cancelar esta consulta.'
      end
    end

    def reschedule
      if @medical_appointment.can_be_rescheduled?
        new_time = Time.zone.parse(params[:new_time])
        MedicalAppointmentService.reschedule_appointment(@medical_appointment, new_time, params[:reason])
        redirect_to admin_medical_appointment_path(@medical_appointment), notice: 'Consulta reagendada com sucesso.'
      else
        redirect_to admin_medical_appointment_path(@medical_appointment),
                    alert: 'Não é possível reagendar esta consulta.'
      end
    end

    def complete
      MedicalAppointmentService.complete_appointment(@medical_appointment, params[:notes])
      redirect_to admin_medical_appointment_path(@medical_appointment), notice: 'Consulta marcada como concluída.'
    end

    def mark_no_show
      MedicalAppointmentService.mark_no_show(@medical_appointment, params[:reason])
      redirect_to admin_medical_appointment_path(@medical_appointment),
                  notice: 'Consulta marcada como não comparecimento.'
    end

    def reports
      @date = params[:date] ? Date.parse(params[:date]) : Date.current
      @week_start = params[:week_start] ? Date.parse(params[:week_start]) : Date.current.beginning_of_week
      @month_start = params[:month_start] ? Date.parse(params[:month_start]) : Date.current.beginning_of_month

      @daily_report = MedicalAppointmentService.generate_daily_report(@date)
      @weekly_report = MedicalAppointmentService.generate_weekly_report(@week_start)
      @monthly_report = MedicalAppointmentService.generate_monthly_report(@month_start)

      @professionals = User.joins(:professional).where(professionals: { active: true })
    end

    def professional_report
      @professional = User.find(params[:professional_id])
      @date_range = params[:date_range] ? Date.parse(params[:date_range])..Date.parse(params[:date_end]) : 1.month.ago..Date.current

      @report = MedicalAppointmentService.generate_occupation_report(@professional, @date_range)
      @appointments = MedicalAppointment.where(professional: @professional, scheduled_at: @date_range)
                                        .includes(:agenda, :patient)
                                        .order(:scheduled_at)
    end

    private

    def set_medical_appointment
      @medical_appointment = MedicalAppointment.find(params[:id])
    end

    def authorize_medical_appointment
      authorize :medical_appointment, :index?
    end

    def medical_appointment_params
      params.expect(
        medical_appointment: %i[agenda_id professional_id patient_id appointment_type status priority
                                scheduled_at duration_minutes notes cancellation_reason reschedule_reason
                                no_show_reason completion_notes]
      )
    end
  end
end
