# frozen_string_literal: true

class AgendaNotificationMailer < ApplicationMailer
  default from: 'noreply@integrar.com.br'

  def schedule_changed(user, agenda)
    @user = user
    @agenda = agenda
    @changes = agenda.previous_changes

    mail(
      to: @user.email,
      subject: "Alterações na agenda '#{@agenda.name}'"
    )
  end

  def agenda_created(user, agenda)
    @user = user
    @agenda = agenda

    mail(
      to: @user.email,
      subject: "Nova agenda criada: '#{@agenda.name}'"
    )
  end

  def conflicts_detected(user, agenda, conflicts)
    @user = user
    @agenda = agenda
    @conflicts = conflicts

    mail(
      to: @user.email,
      subject: "Conflitos detectados na agenda '#{@agenda.name}'"
    )
  end

  def low_occupancy_alert(user, agenda)
    @user = user
    @agenda = agenda
    @occupancy_rate = agenda.occupancy_rate

    mail(
      to: @user.email,
      subject: "Baixa ocupação na agenda '#{@agenda.name}'"
    )
  end

  def maintenance_reminder(user, agenda)
    @user = user
    @agenda = agenda
    @last_updated = agenda.updated_at

    mail(
      to: @user.email,
      subject: "Lembrete de manutenção: '#{@agenda.name}'"
    )
  end

  def inactive_agenda_alert(user, agenda)
    @user = user
    @agenda = agenda
    @last_event = agenda.events.order(:start_time).last

    mail(
      to: @user.email,
      subject: "Agenda inativa: '#{@agenda.name}'"
    )
  end

  def admin_schedule_changed(admin, agenda)
    @admin = admin
    @agenda = agenda
    @changes = agenda.previous_changes

    mail(
      to: @admin.email,
      subject: "[ADMIN] Alterações na agenda '#{@agenda.name}'"
    )
  end

  def admin_new_agenda(admin, agenda)
    @admin = admin
    @agenda = agenda

    mail(
      to: @admin.email,
      subject: "[ADMIN] Nova agenda criada: '#{@agenda.name}'"
    )
  end

  def admin_conflicts_detected(admin, agenda, conflicts)
    @admin = admin
    @agenda = agenda
    @conflicts = conflicts

    mail(
      to: @admin.email,
      subject: "[ADMIN] Conflitos detectados na agenda '#{@agenda.name}'"
    )
  end
end
