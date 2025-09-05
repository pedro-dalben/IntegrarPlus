class NotificationMailer < ApplicationMailer
  default from: 'noreply@integrar.com.br'
  
  def send_notification(notification, subject, body)
    @notification = notification
    @user = notification.user
    @subject = subject
    @body = body
    
    mail(
      to: @user.email,
      subject: @subject
    )
  end
  
  def generic_notification(notification)
    @notification = notification
    @user = notification.user
    
    mail(
      to: @user.email,
      subject: @notification.title
    )
  end
  
  def appointment_scheduled(notification)
    @notification = notification
    @user = notification.user
    @appointment = MedicalAppointment.find(@notification.metadata['appointment_id'])
    
    mail(
      to: @user.email,
      subject: "Consulta agendada - #{@appointment.agenda.name}"
    )
  end
  
  def appointment_reminder(notification)
    @notification = notification
    @user = notification.user
    @appointment = MedicalAppointment.find(@notification.metadata['appointment_id'])
    
    mail(
      to: @user.email,
      subject: "Lembrete: Consulta #{@notification.metadata['reminder_type']} - #{@appointment.agenda.name}"
    )
  end
  
  def conflict_alert(notification)
    @notification = notification
    @user = notification.user
    @agenda = Agenda.find(@notification.metadata['agenda_id'])
    @conflicts = @notification.metadata['conflicts']
    
    mail(
      to: @user.email,
      subject: "Conflitos detectados na agenda '#{@agenda.name}'"
    )
  end
  
  def emergency_alert(notification)
    @notification = notification
    @user = notification.user
    @appointment = MedicalAppointment.find(@notification.metadata['appointment_id'])
    
    mail(
      to: @user.email,
      subject: "ALERTA: Consulta de emergência agendada"
    )
  end
  
  def daily_report(notification)
    @notification = notification
    @user = notification.user
    @appointments_count = @notification.metadata['appointments_count']
    @date = @notification.metadata['date']
    
    mail(
      to: @user.email,
      subject: "Agenda do dia - #{@date}"
    )
  end
  
  def weekly_summary(notification)
    @notification = notification
    @user = notification.user
    @alerts_count = @notification.metadata['alerts_count']
    @metrics = @notification.metadata['metrics']
    @week_start = @notification.metadata['week_start']
    
    mail(
      to: @user.email,
      subject: "Relatório semanal - #{@week_start}"
    )
  end
end
