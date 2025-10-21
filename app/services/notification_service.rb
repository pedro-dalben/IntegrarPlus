# frozen_string_literal: true

class NotificationService
  def self.create_notification(user, type, title, message, options = {})
    notification = Notification.create!(
      user: user,
      type: type,
      title: title,
      message: message,
      metadata: options[:metadata] || {},
      scheduled_at: options[:scheduled_at],
      channel: options[:channel] || 'email'
    )

    deliver(notification) if options[:send_immediately]

    notification
  end

  def self.deliver(notification)
    return unless notification.can_be_sent?

    begin
      case notification.channel
      when 'email'
        deliver_email(notification)
      when 'sms'
        deliver_sms(notification)
      when 'push'
        deliver_push(notification)
      when 'in_app'
        deliver_in_app(notification)
      end

      notification.update!(status: 'sent', sent_at: Time.current)

      # Broadcast para WebSocket se for notificação in-app
      if notification.channel == 'in_app'
        NotificationChannel.broadcast_to(notification.user, {
                                           type: 'notification',
                                           id: notification.id,
                                           title: notification.title,
                                           message: notification.message,
                                           created_at: notification.created_at
                                         })
      end
    rescue StandardError => e
      notification.update!(status: 'failed', error_message: e.message)
      Rails.logger.error "Failed to deliver notification #{notification.id}: #{e.message}"
      raise e
    end
  end

  def self.schedule_reminder(appointment, reminder_type)
    case reminder_type
    when '48h'
      scheduled_at = appointment.scheduled_at - 48.hours
    when '24h'
      scheduled_at = appointment.scheduled_at - 24.hours
    when '2h'
      scheduled_at = appointment.scheduled_at - 2.hours
    end

    return if scheduled_at < Time.current

    # Verificar preferências do usuário
    preference = NotificationPreference.get_preference(appointment.patient, 'appointment_reminder')
    return unless preference.has_enabled_channels?

    preference.enabled_channels.each do |channel|
      create_notification(
        appointment.patient,
        'appointment_reminder',
        "Lembrete de consulta - #{appointment.agenda.name}",
        build_reminder_message(appointment, reminder_type),
        scheduled_at: scheduled_at,
        channel: channel,
        metadata: {
          appointment_id: appointment.id,
          reminder_type: reminder_type,
          agenda_name: appointment.agenda.name,
          professional_name: appointment.professional.full_name,
          appointment_date: appointment.scheduled_at.strftime('%d/%m/%Y'),
          appointment_time: appointment.scheduled_at.strftime('%H:%M')
        }
      )
    end
  end

  def self.send_agenda_conflict_alert(agenda, conflicts)
    agenda.professionals.each do |professional|
      preference = NotificationPreference.get_preference(professional.user, 'conflict_detected')
      return unless preference.has_enabled_channels?

      preference.enabled_channels.each do |channel|
        create_notification(
          professional.user,
          'conflict_detected',
          "Conflitos detectados na agenda '#{agenda.name}'",
          "Foram detectados #{conflicts.count} conflitos de horário na sua agenda.",
          channel: channel,
          metadata: {
            agenda_id: agenda.id,
            conflicts: conflicts,
            agenda_name: agenda.name
          },
          send_immediately: true
        )
      end
    end
  end

  def self.send_appointment_notification(appointment, notification_type)
    case notification_type
    when 'scheduled'
      send_appointment_scheduled_notification(appointment)
    when 'cancelled'
      send_appointment_cancelled_notification(appointment)
    when 'rescheduled'
      send_appointment_rescheduled_notification(appointment)
    when 'completed'
      send_appointment_completed_notification(appointment)
    when 'no_show'
      send_appointment_no_show_notification(appointment)
    end
  end

  def self.send_emergency_alert(appointment)
    # Notificar profissional
    preference = NotificationPreference.get_preference(appointment.professional, 'emergency_alert')
    return unless preference.has_enabled_channels?

    preference.enabled_channels.each do |channel|
      create_notification(
        appointment.professional,
        'emergency_alert',
        'ALERTA: Consulta de emergência agendada',
        "Consulta de emergência agendada para #{appointment.scheduled_at.strftime('%d/%m/%Y às %H:%M')}",
        channel: channel,
        metadata: {
          appointment_id: appointment.id,
          appointment_time: appointment.scheduled_at.strftime('%H:%M'),
          patient_name: appointment.patient&.full_name
        },
        send_immediately: true
      )
    end
  end

  def self.send_daily_report(professional, appointments)
    preference = NotificationPreference.get_preference(professional, 'daily_report')
    return unless preference.has_enabled_channels?

    preference.enabled_channels.each do |channel|
      create_notification(
        professional,
        'daily_report',
        "Agenda do dia - #{Date.current.strftime('%d/%m/%Y')}",
        build_daily_report_message(appointments),
        channel: channel,
        metadata: {
          appointments_count: appointments.count,
          date: Date.current.strftime('%d/%m/%Y')
        },
        send_immediately: true
      )
    end
  end

  def self.send_weekly_summary(admin_user, alerts, metrics)
    preference = NotificationPreference.get_preference(admin_user, 'weekly_report')
    return unless preference.has_enabled_channels?

    preference.enabled_channels.each do |channel|
      create_notification(
        admin_user,
        'weekly_report',
        "Relatório semanal - #{Date.current.strftime('%d/%m/%Y')}",
        build_weekly_summary_message(alerts, metrics),
        channel: channel,
        metadata: {
          alerts_count: alerts.count,
          metrics: metrics,
          week_start: Date.current.beginning_of_week.strftime('%d/%m/%Y')
        },
        send_immediately: true
      )
    end
  end

  def self.process_scheduled_notifications
    Notification.where(
      status: 'pending',
      scheduled_at: ..Time.current
    ).find_each do |notification|
      NotificationDeliveryJob.perform_later(notification.id)
    end
  end

  def self.cleanup_old_notifications(days = 30)
    Notification.where(created_at: ...days.days.ago).destroy_all
  end

  def self.deliver_email(notification)
    template = NotificationTemplate.find_for_type_and_channel(notification.type, 'email')

    if template
      rendered = template.render(notification.metadata || {})
      NotificationMailer.send_notification(notification, rendered[:subject], rendered[:body]).deliver_now
    else
      NotificationMailer.generic_notification(notification).deliver_now
    end
  end

  def self.deliver_sms(notification)
    # Implementar integração com provedor de SMS
    # Exemplo: Twilio, AWS SNS, etc.
    Rails.logger.info "SMS notification sent to #{notification.user.email}: #{notification.title}"
  end

  def self.deliver_push(notification)
    # Implementar notificações push
    # Exemplo: Firebase, OneSignal, etc.
    Rails.logger.info "Push notification sent to #{notification.user.email}: #{notification.title}"
  end

  def self.deliver_in_app(notification)
    # Notificação já está no banco de dados
    # Será exibida via WebSocket
    Rails.logger.info "In-app notification created for #{notification.user.email}: #{notification.title}"
  end

  def self.build_reminder_message(appointment, reminder_type)
    case reminder_type
    when '48h'
      "Lembrete: Você tem uma consulta agendada para depois de amanhã (#{appointment.scheduled_at.strftime('%d/%m/%Y às %H:%M')}) com #{appointment.professional.full_name} na agenda #{appointment.agenda.name}."
    when '24h'
      "Lembrete: Você tem uma consulta agendada para amanhã (#{appointment.scheduled_at.strftime('%d/%m/%Y às %H:%M')}) com #{appointment.professional.full_name} na agenda #{appointment.agenda.name}."
    when '2h'
      "Lembrete: Você tem uma consulta agendada em 2 horas (#{appointment.scheduled_at.strftime('%H:%M')}) com #{appointment.professional.full_name} na agenda #{appointment.agenda.name}."
    end
  end

  def self.send_appointment_scheduled_notification(appointment)
    preference = NotificationPreference.get_preference(appointment.patient, 'appointment_scheduled')
    return unless preference.has_enabled_channels?

    preference.enabled_channels.each do |channel|
      create_notification(
        appointment.patient,
        'appointment_scheduled',
        "Consulta agendada - #{appointment.agenda.name}",
        "Sua consulta foi agendada para #{appointment.scheduled_at.strftime('%d/%m/%Y às %H:%M')} com #{appointment.professional.full_name}.",
        channel: channel,
        metadata: {
          appointment_id: appointment.id,
          agenda_name: appointment.agenda.name,
          professional_name: appointment.professional.full_name,
          appointment_date: appointment.scheduled_at.strftime('%d/%m/%Y'),
          appointment_time: appointment.scheduled_at.strftime('%H:%M')
        },
        send_immediately: true
      )
    end
  end

  def self.send_appointment_cancelled_notification(appointment)
    preference = NotificationPreference.get_preference(appointment.patient, 'appointment_cancelled')
    return unless preference.has_enabled_channels?

    preference.enabled_channels.each do |channel|
      create_notification(
        appointment.patient,
        'appointment_cancelled',
        "Consulta cancelada - #{appointment.agenda.name}",
        "Sua consulta de #{appointment.scheduled_at.strftime('%d/%m/%Y às %H:%M')} foi cancelada.",
        channel: channel,
        metadata: {
          appointment_id: appointment.id,
          agenda_name: appointment.agenda.name,
          appointment_date: appointment.scheduled_at.strftime('%d/%m/%Y'),
          appointment_time: appointment.scheduled_at.strftime('%H:%M'),
          cancellation_reason: appointment.cancellation_reason
        },
        send_immediately: true
      )
    end
  end

  def self.send_appointment_rescheduled_notification(appointment)
    preference = NotificationPreference.get_preference(appointment.patient, 'appointment_rescheduled')
    return unless preference.has_enabled_channels?

    preference.enabled_channels.each do |channel|
      create_notification(
        appointment.patient,
        'appointment_rescheduled',
        "Consulta reagendada - #{appointment.agenda.name}",
        "Sua consulta foi reagendada para #{appointment.scheduled_at.strftime('%d/%m/%Y às %H:%M')}.",
        channel: channel,
        metadata: {
          appointment_id: appointment.id,
          agenda_name: appointment.agenda.name,
          appointment_date: appointment.scheduled_at.strftime('%d/%m/%Y'),
          appointment_time: appointment.scheduled_at.strftime('%H:%M'),
          reschedule_reason: appointment.reschedule_reason
        },
        send_immediately: true
      )
    end
  end

  def self.send_appointment_completed_notification(appointment)
    preference = NotificationPreference.get_preference(appointment.patient, 'appointment_completed')
    return unless preference.has_enabled_channels?

    preference.enabled_channels.each do |channel|
      create_notification(
        appointment.patient,
        'appointment_completed',
        "Consulta concluída - #{appointment.agenda.name}",
        "Sua consulta de #{appointment.scheduled_at.strftime('%d/%m/%Y às %H:%M')} foi concluída com sucesso.",
        channel: channel,
        metadata: {
          appointment_id: appointment.id,
          agenda_name: appointment.agenda.name,
          appointment_date: appointment.scheduled_at.strftime('%d/%m/%Y'),
          appointment_time: appointment.scheduled_at.strftime('%H:%M')
        },
        send_immediately: true
      )
    end
  end

  def self.send_appointment_no_show_notification(appointment)
    preference = NotificationPreference.get_preference(appointment.patient, 'appointment_no_show')
    return unless preference.has_enabled_channels?

    preference.enabled_channels.each do |channel|
      create_notification(
        appointment.patient,
        'appointment_no_show',
        "Não comparecimento - #{appointment.agenda.name}",
        "Você não compareceu à consulta de #{appointment.scheduled_at.strftime('%d/%m/%Y às %H:%M')}. Entre em contato para reagendar.",
        channel: channel,
        metadata: {
          appointment_id: appointment.id,
          agenda_name: appointment.agenda.name,
          appointment_date: appointment.scheduled_at.strftime('%d/%m/%Y'),
          appointment_time: appointment.scheduled_at.strftime('%H:%M'),
          no_show_reason: appointment.no_show_reason
        },
        send_immediately: true
      )
    end
  end

  def self.build_daily_report_message(appointments)
    if appointments.empty?
      'Você não tem consultas agendadas para hoje.'
    else
      message = "Você tem #{appointments.count} consulta(s) agendada(s) para hoje:\n\n"
      appointments.each do |appointment|
        message += "• #{appointment.scheduled_at.strftime('%H:%M')} - #{appointment.patient&.full_name || 'Paciente não informado'}\n"
      end
      message
    end
  end

  def self.build_weekly_summary_message(alerts, metrics)
    message = "Relatório semanal do sistema de agendas:\n\n"
    message += "Métricas:\n"
    message += "• Total de agendas: #{metrics[:total_agendas]}\n"
    message += "• Total de profissionais: #{metrics[:total_professionals]}\n"
    message += "• Total de eventos: #{metrics[:total_events]}\n"
    message += "• Taxa média de ocupação: #{metrics[:average_occupancy]}%\n\n"

    if alerts.any?
      message += "Alertas:\n"
      alerts.each do |alert|
        message += "• #{alert[:message]}\n"
      end
    else
      message += 'Nenhum alerta crítico esta semana.'
    end

    message
  end
end
