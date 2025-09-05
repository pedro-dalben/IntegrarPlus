class MedicalAppointmentService
  def initialize(appointment)
    @appointment = appointment
  end

  def self.create_appointment(params)
    appointment = MedicalAppointment.new(params)

    if appointment.save
      appointment.send_notifications
      schedule_reminders(appointment)
      appointment
    else
      appointment
    end
  end

  def self.update_appointment(appointment, params)
    old_status = appointment.status

    if appointment.update(params)
      if old_status != appointment.status
        appointment.send_notifications
      end
      appointment
    else
      appointment
    end
  end

  def self.cancel_appointment(appointment, reason = nil)
    appointment.update!(
      status: 'cancelled',
      cancellation_reason: reason,
      cancelled_at: Time.current
    )

    appointment.send_notifications
    cancel_reminders(appointment)
    appointment
  end

  def self.reschedule_appointment(appointment, new_time, reason = nil)
    old_time = appointment.scheduled_at

    appointment.update!(
      scheduled_at: new_time,
      status: 'rescheduled',
      reschedule_reason: reason,
      rescheduled_at: Time.current
    )

    appointment.send_notifications
    reschedule_reminders(appointment, old_time, new_time)
    appointment
  end

  def self.complete_appointment(appointment, notes = nil)
    appointment.update!(
      status: 'completed',
      completed_at: Time.current,
      completion_notes: notes
    )

    appointment.send_notifications
    appointment
  end

  def self.mark_no_show(appointment, reason = nil)
    appointment.update!(
      status: 'no_show',
      no_show_reason: reason,
      no_show_at: Time.current
    )

    appointment.send_notifications
    appointment
  end

  def self.send_daily_reminders
    send_reminders_for_date(1.day.from_now, '24h')
  end

  def self.send_weekly_reminders
    send_reminders_for_date(2.days.from_now, '48h')
  end

  def self.send_reminders_for_date(date, reminder_type)
    appointments = MedicalAppointment.where(
      scheduled_at: date.beginning_of_day..date.end_of_day,
      status: ['scheduled', 'confirmed']
    )

    appointments.each do |appointment|
      case reminder_type
      when '24h'
        MedicalAppointmentMailer.reminder_24h(appointment).deliver_later
      when '48h'
        MedicalAppointmentMailer.reminder_48h(appointment).deliver_later
      end
    end
  end

  def self.send_daily_schedules
    professionals = User.joins(:professional).where(professionals: { active: true })

    professionals.each do |professional|
      appointments = MedicalAppointment.where(
        professional: professional,
        scheduled_at: Date.current.all_day,
        status: ['scheduled', 'confirmed']
      ).order(:scheduled_at)

      if appointments.any?
        MedicalAppointmentMailer.daily_schedule(professional, appointments).deliver_later
      end
    end
  end

  def self.send_weekly_schedules
    professionals = User.joins(:professional).where(professionals: { active: true })

    professionals.each do |professional|
      appointments = MedicalAppointment.where(
        professional: professional,
        scheduled_at: Date.current.beginning_of_week..Date.current.end_of_week,
        status: ['scheduled', 'confirmed']
      ).order(:scheduled_at)

      if appointments.any?
        MedicalAppointmentMailer.weekly_schedule(professional, appointments).deliver_later
      end
    end
  end

  def self.generate_occupation_report(professional, date_range)
    {
      professional: professional,
      date_range: date_range,
      total_appointments: MedicalAppointment.where(professional: professional, scheduled_at: date_range).count,
      completed_appointments: MedicalAppointment.where(professional: professional, scheduled_at: date_range, status: 'completed').count,
      cancelled_appointments: MedicalAppointment.where(professional: professional, scheduled_at: date_range, status: 'cancelled').count,
      no_show_appointments: MedicalAppointment.where(professional: professional, scheduled_at: date_range, status: 'no_show').count,
      occupation_rate: MedicalAppointment.occupation_rate(professional, date_range),
      completion_rate: MedicalAppointment.completion_rate(professional, date_range),
      no_show_rate: MedicalAppointment.no_show_rate(professional, date_range),
      average_duration: MedicalAppointment.average_duration(professional, date_range)
    }
  end

  def self.generate_daily_report(date = Date.current)
    appointments = MedicalAppointment.where(scheduled_at: date.all_day)

    {
      date: date,
      total_appointments: appointments.count,
      by_status: appointments.group(:status).count,
      by_type: appointments.group(:appointment_type).count,
      by_priority: appointments.group(:priority).count,
      by_professional: appointments.joins(:professional).group('users.name').count,
      completion_rate: appointments.where(status: 'completed').count.to_f / appointments.count * 100,
      no_show_rate: appointments.where(status: 'no_show').count.to_f / appointments.count * 100
    }
  end

  def self.generate_weekly_report(week_start = Date.current.beginning_of_week)
    week_end = week_start.end_of_week
    appointments = MedicalAppointment.where(scheduled_at: week_start..week_end)

    {
      week_start: week_start,
      week_end: week_end,
      total_appointments: appointments.count,
      by_status: appointments.group(:status).count,
      by_type: appointments.group(:appointment_type).count,
      by_priority: appointments.group(:priority).count,
      by_professional: appointments.joins(:professional).group('users.name').count,
      by_day: appointments.group("DATE(scheduled_at)").count,
      completion_rate: appointments.where(status: 'completed').count.to_f / appointments.count * 100,
      no_show_rate: appointments.where(status: 'no_show').count.to_f / appointments.count * 100
    }
  end

  def self.generate_monthly_report(month_start = Date.current.beginning_of_month)
    month_end = month_start.end_of_month
    appointments = MedicalAppointment.where(scheduled_at: month_start..month_end)

    {
      month_start: month_start,
      month_end: month_end,
      total_appointments: appointments.count,
      by_status: appointments.group(:status).count,
      by_type: appointments.group(:appointment_type).count,
      by_priority: appointments.group(:priority).count,
      by_professional: appointments.joins(:professional).group('users.name').count,
      by_week: appointments.group("DATE_TRUNC('week', scheduled_at)").count,
      completion_rate: appointments.where(status: 'completed').count.to_f / appointments.count * 100,
      no_show_rate: appointments.where(status: 'no_show').count.to_f / appointments.count * 100
    }
  end

  def self.check_emergency_appointments
    emergency_appointments = MedicalAppointment.where(
      priority: 'urgent',
      status: ['scheduled', 'confirmed'],
      scheduled_at: Time.current..1.hour.from_now
    )

    emergency_appointments.each do |appointment|
      MedicalAppointmentMailer.emergency_alert(appointment).deliver_later
    end

    emergency_appointments
  end

  def self.check_overdue_appointments
    overdue_appointments = MedicalAppointment.where(
      status: ['scheduled', 'confirmed'],
      scheduled_at: 1.hour.ago..Time.current
    )

    overdue_appointments.each do |appointment|
      appointment.update!(status: 'no_show', no_show_at: Time.current)
      appointment.send_notifications
    end

    overdue_appointments
  end

  private

  def self.schedule_reminders(appointment)
    # Agendar lembrete 24h antes
    ReminderJob.set(wait_until: appointment.scheduled_at - 24.hours)
              .perform_later(appointment.id, '24h')

    # Agendar lembrete 48h antes
    ReminderJob.set(wait_until: appointment.scheduled_at - 48.hours)
              .perform_later(appointment.id, '48h')
  end

  def self.cancel_reminders(appointment)
    # Cancelar lembretes agendados
    # Implementar cancelamento de jobs agendados
  end

  def self.reschedule_reminders(appointment, old_time, new_time)
    # Cancelar lembretes antigos
    cancel_reminders(appointment)

    # Agendar novos lembretes
    schedule_reminders(appointment)
  end
end
