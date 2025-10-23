# frozen_string_literal: true

class AppointmentSchedulingService
  def initialize(professional, agenda)
    @professional = professional
    @agenda = agenda
  end

  def schedule_appointment(appointment_data)
    return { success: false, error: 'Dados de agendamento inválidos' } unless valid_appointment_data?(appointment_data)

    scheduled_datetime = appointment_data[:scheduled_datetime]
    duration_minutes = appointment_data[:duration_minutes] || @agenda.slot_duration_minutes

    availability_check = check_availability(scheduled_datetime, duration_minutes)
    unless availability_check[:available]
      return { success: false, error: 'Horário não disponível',
               conflicts: availability_check[:conflicts] }
    end

    ActiveRecord::Base.transaction do
      event = create_event(appointment_data, scheduled_datetime, duration_minutes)
      medical_appointment = create_medical_appointment(appointment_data, scheduled_datetime, duration_minutes, event)

      send_notifications(event, medical_appointment)

      { success: true, event: event, medical_appointment: medical_appointment }
    end
  rescue StandardError => e
    { success: false, error: e.message }
  end

  def check_availability(datetime, duration_minutes = nil)
    duration_minutes ||= @agenda.slot_duration_minutes
    end_time = datetime + duration_minutes.minutes

    Rails.logger.debug { "🔍 Verificando disponibilidade: #{datetime} - #{end_time} (#{duration_minutes} min)" }

    conflicts = []

    existing_events = Event.where(professional: @professional)
                           .where('start_time < ? AND end_time > ?', end_time, datetime)
                           .active_events

    conflicts.concat(existing_events.map { |event| { type: 'event', object: event } })

    existing_appointments = MedicalAppointment.where(professional: @professional)
                                              .where('scheduled_at < ? AND scheduled_at + interval \'1 minute\' * duration_minutes > ?', end_time, datetime)
                                              .where.not(status: %w[cancelled no_show])

    conflicts.concat(existing_appointments.map { |appointment| { type: 'appointment', object: appointment } })

    # Buscar exceções de disponibilidade através do Professional
    # @professional pode ser User ou Professional, então precisamos acessar corretamente
    professional_record = @professional.is_a?(User) ? @professional.professional : @professional

    if professional_record.present?
      availability_exceptions = professional_record.availability_exceptions
                                                   .where(agenda: @agenda)
                                                   .for_date(datetime.to_date)
                                                   .active
                                                   .select { |exception| exception.blocks_time?(datetime) }

      conflicts.concat(availability_exceptions.map { |exception| { type: 'exception', object: exception } })
    end

    result = {
      available: conflicts.empty?,
      conflicts: conflicts,
      datetime: datetime,
      end_time: end_time,
      duration_minutes: duration_minutes
    }

    Rails.logger.debug { "📋 Resultado da verificação: #{result}" }

    result
  end

  def get_available_slots(date, duration_minutes = nil)
    duration_minutes ||= @agenda.slot_duration_minutes

    # @professional pode ser User ou Professional
    professional_record = @professional.is_a?(User) ? @professional.professional : @professional

    return [] if professional_record.blank?

    availabilities = professional_record.professional_availabilities
                                        .where(agenda: @agenda)
                                        .for_day(date.wday)
                                        .active

    return [] if availabilities.empty?

    slots = []
    availabilities.each do |availability|
      time_slots = availability.time_slots(duration_minutes, @agenda.buffer_minutes)

      time_slots.each do |slot|
        slot_datetime = DateTime.parse("#{date.strftime('%Y-%m-%d')} #{slot[:start_time].strftime('%H:%M')}")
        availability_check = check_availability(slot_datetime, duration_minutes)

        slots << {
          start_time: slot_datetime,
          end_time: slot_datetime + duration_minutes.minutes,
          available: availability_check[:available],
          conflicts: availability_check[:conflicts]
        }
      end
    end

    slots.sort_by { |slot| slot[:start_time] }
  end

  def reschedule_appointment(appointment, new_datetime, new_duration_minutes = nil)
    new_duration_minutes ||= appointment.duration_minutes

    availability_check = check_availability(new_datetime, new_duration_minutes)
    unless availability_check[:available]
      return { success: false, error: 'Novo horário não disponível',
               conflicts: availability_check[:conflicts] }
    end

    ActiveRecord::Base.transaction do
      old_datetime = appointment.scheduled_at

      appointment.update!(
        scheduled_at: new_datetime,
        duration_minutes: new_duration_minutes,
        status: 'rescheduled'
      )

      if appointment.event.present?
        appointment.event.update!(
          start_time: new_datetime,
          end_time: new_datetime + new_duration_minutes.minutes
        )
      end

      send_reschedule_notifications(appointment, old_datetime, new_datetime)

      { success: true, appointment: appointment }
    end
  rescue StandardError => e
    { success: false, error: e.message }
  end

  def cancel_appointment(appointment, reason = nil)
    return { success: false, error: 'Agendamento não pode ser cancelado' } unless appointment.can_be_cancelled?

    ActiveRecord::Base.transaction do
      appointment.update!(status: 'cancelled')

      appointment.event.update!(status: 'cancelled') if appointment.event.present?

      send_cancellation_notifications(appointment, reason)

      { success: true, appointment: appointment }
    end
  rescue StandardError => e
    { success: false, error: e.message }
  end

  private

  def create_event(appointment_data, scheduled_datetime, duration_minutes)
    Event.create!(
      title: appointment_data[:title] || "Agendamento - #{@professional.full_name}",
      description: appointment_data[:description],
      start_time: scheduled_datetime,
      end_time: scheduled_datetime + duration_minutes.minutes,
      event_type: map_appointment_type_to_event_type(appointment_data[:appointment_type]),
      visibility_level: 'restricted',
      professional: @professional,
      created_by: appointment_data[:created_by] || @professional,
      status: 'active',
      source_context: appointment_data[:source_context]
    )
  end

  def create_medical_appointment(appointment_data, scheduled_datetime, duration_minutes, event)
    MedicalAppointment.create!(
      agenda: @agenda,
      professional: @professional,
      patient: appointment_data[:patient],
      appointment_type: appointment_data[:appointment_type] || 'initial_consultation',
      status: 'scheduled',
      priority: appointment_data[:priority] || 'normal',
      scheduled_at: scheduled_datetime,
      duration_minutes: duration_minutes,
      notes: appointment_data[:notes],
      event: event
    )
  end

  def map_appointment_type_to_event_type(appointment_type)
    case appointment_type
    when 'initial_consultation', 'return_consultation'
      'consulta'
    when 'emergency_consultation'
      'atendimento'
    when 'procedure'
      'atendimento'
    when 'exam'
      'atendimento'
    when 'therapy'
      'atendimento'
    when 'evaluation'
      'consulta'
    else
      'outro'
    end
  end

  def send_notifications(_event, medical_appointment)
    if medical_appointment.patient.present?
      MedicalAppointmentMailer.appointment_scheduled(medical_appointment).deliver_later
    end

    MedicalAppointmentMailer.professional_notification(medical_appointment).deliver_later
  end

  def send_reschedule_notifications(appointment, _old_datetime, _new_datetime)
    MedicalAppointmentMailer.appointment_rescheduled(appointment).deliver_later if appointment.patient.present?

    MedicalAppointmentMailer.professional_reschedule(appointment).deliver_later
  end

  def send_cancellation_notifications(appointment, _reason)
    MedicalAppointmentMailer.appointment_cancelled(appointment).deliver_later if appointment.patient.present?

    MedicalAppointmentMailer.professional_cancellation(appointment).deliver_later
  end

  def valid_appointment_data?(appointment_data)
    appointment_data[:scheduled_datetime].present? &&
      appointment_data[:appointment_type].present?
  end
end
