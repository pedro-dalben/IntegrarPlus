class MedicalAppointmentMailer < ApplicationMailer
  def appointment_scheduled(appointment)
    @appointment = appointment
    @patient = appointment.patient
    @professional = appointment.professional
    @agenda = appointment.agenda

    mail(
      to: @patient.email,
      subject: "Consulta agendada - #{@agenda.name}",
      template_name: 'appointment_scheduled'
    )
  end

  def appointment_confirmed(appointment)
    @appointment = appointment
    @patient = appointment.patient
    @professional = appointment.professional
    @agenda = appointment.agenda

    mail(
      to: @patient.email,
      subject: "Consulta confirmada - #{@agenda.name}",
      template_name: 'appointment_confirmed'
    )
  end

  def appointment_cancelled(appointment)
    @appointment = appointment
    @patient = appointment.patient
    @professional = appointment.professional
    @agenda = appointment.agenda

    mail(
      to: @patient.email,
      subject: "Consulta cancelada - #{@agenda.name}",
      template_name: 'appointment_cancelled'
    )
  end

  def appointment_rescheduled(appointment)
    @appointment = appointment
    @patient = appointment.patient
    @professional = appointment.professional
    @agenda = appointment.agenda

    mail(
      to: @patient.email,
      subject: "Consulta reagendada - #{@agenda.name}",
      template_name: 'appointment_rescheduled'
    )
  end

  def appointment_completed(appointment)
    @appointment = appointment
    @patient = appointment.patient
    @professional = appointment.professional
    @agenda = appointment.agenda

    mail(
      to: @patient.email,
      subject: "Consulta concluída - #{@agenda.name}",
      template_name: 'appointment_completed'
    )
  end

  def appointment_no_show(appointment)
    @appointment = appointment
    @patient = appointment.patient
    @professional = appointment.professional
    @agenda = appointment.agenda

    mail(
      to: @patient.email,
      subject: "Não comparecimento - #{@agenda.name}",
      template_name: 'appointment_no_show'
    )
  end

  def professional_notification(appointment)
    @appointment = appointment
    @patient = appointment.patient
    @professional = appointment.professional
    @agenda = appointment.agenda

    mail(
      to: @professional.email,
      subject: "Nova consulta agendada - #{@agenda.name}",
      template_name: 'professional_notification'
    )
  end

  def professional_confirmation(appointment)
    @appointment = appointment
    @patient = appointment.patient
    @professional = appointment.professional
    @agenda = appointment.agenda

    mail(
      to: @professional.email,
      subject: "Consulta confirmada - #{@agenda.name}",
      template_name: 'professional_confirmation'
    )
  end

  def professional_cancellation(appointment)
    @appointment = appointment
    @patient = appointment.patient
    @professional = appointment.professional
    @agenda = appointment.agenda

    mail(
      to: @professional.email,
      subject: "Consulta cancelada - #{@agenda.name}",
      template_name: 'professional_cancellation'
    )
  end

  def professional_reschedule(appointment)
    @appointment = appointment
    @patient = appointment.patient
    @professional = appointment.professional
    @agenda = appointment.agenda

    mail(
      to: @professional.email,
      subject: "Consulta reagendada - #{@agenda.name}",
      template_name: 'professional_reschedule'
    )
  end

  def professional_no_show(appointment)
    @appointment = appointment
    @patient = appointment.patient
    @professional = appointment.professional
    @agenda = appointment.agenda

    mail(
      to: @professional.email,
      subject: "Paciente não compareceu - #{@agenda.name}",
      template_name: 'professional_no_show'
    )
  end

  def daily_schedule(professional, appointments)
    @professional = professional
    @appointments = appointments
    @date = Date.current

    mail(
      to: @professional.email,
      subject: "Agenda do dia - #{@date.strftime('%d/%m/%Y')}",
      template_name: 'daily_schedule'
    )
  end

  def weekly_schedule(professional, appointments)
    @professional = professional
    @appointments = appointments
    @week_start = Date.current.beginning_of_week
    @week_end = Date.current.end_of_week

    mail(
      to: @professional.email,
      subject: "Agenda da semana - #{@week_start.strftime('%d/%m')} a #{@week_end.strftime('%d/%m/%Y')}",
      template_name: 'weekly_schedule'
    )
  end

  def emergency_alert(appointment)
    @appointment = appointment
    @patient = appointment.patient
    @professional = appointment.professional
    @agenda = appointment.agenda

    mail(
      to: @professional.email,
      subject: "ALERTA: Consulta de emergência agendada",
      template_name: 'emergency_alert'
    )
  end

  def reminder_24h(appointment)
    @appointment = appointment
    @patient = appointment.patient
    @professional = appointment.professional
    @agenda = appointment.agenda

    mail(
      to: @patient.email,
      subject: "Lembrete: Consulta amanhã - #{@agenda.name}",
      template_name: 'reminder_24h'
    )
  end

  def reminder_48h(appointment)
    @appointment = appointment
    @patient = appointment.patient
    @professional = appointment.professional
    @agenda = appointment.agenda

    mail(
      to: @patient.email,
      subject: "Lembrete: Consulta em 2 dias - #{@agenda.name}",
      template_name: 'reminder_48h'
    )
  end
end
