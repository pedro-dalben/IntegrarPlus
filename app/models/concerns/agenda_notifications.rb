# frozen_string_literal: true

# Módulo para notificações de agendas
module AgendaNotifications
  extend ActiveSupport::Concern

  included do
    after_update :notify_schedule_changes
    after_create :notify_agenda_created
    after_update :notify_conflicts_detected, if: :saved_change_to_working_hours?
  end

  def notify_schedule_changes
    return unless saved_change_to_working_hours?

    professionals.each do |professional|
      AgendaNotificationMailer.schedule_changed(professional.user, self).deliver_later
    end

    notify_admins_about_changes
  end

  def notify_agenda_created
    AgendaNotificationMailer.agenda_created(created_by, self).deliver_later

    notify_admins_about_new_agenda
  end

  def notify_conflicts_detected
    conflicts = check_all_conflicts

    return unless conflicts.any?

    AgendaNotificationMailer.conflicts_detected(created_by, self, conflicts).deliver_later
    notify_admins_about_conflicts(conflicts)
  end

  def notify_low_occupancy
    return unless occupancy_rate < 30

    AgendaNotificationMailer.low_occupancy_alert(created_by, self).deliver_later
  end

  def notify_maintenance_reminder
    return unless needs_maintenance?

    AgendaNotificationMailer.maintenance_reminder(created_by, self).deliver_later
  end

  def notify_inactive_agenda
    return unless inactive_for_too_long?

    AgendaNotificationMailer.inactive_agenda_alert(created_by, self).deliver_later
  end

  private

  def check_all_conflicts
    all_conflicts = []

    professionals.each do |professional|
      working_hours['weekdays']&.each do |day_config|
        day_config['periods']&.each do |period|
          start_time = Time.zone.parse("#{Date.current} #{period['start']}")
          end_time = Time.zone.parse("#{Date.current} #{period['end']}")

          conflicts = check_conflicts_for_professional(professional, start_time, end_time)
          all_conflicts.concat(conflicts)
        end
      end
    end

    all_conflicts
  end

  def notify_admins_about_changes
    admin_users = User.where(role: 'admin')

    admin_users.each do |admin|
      AgendaNotificationMailer.admin_schedule_changed(admin, self).deliver_later
    end
  end

  def notify_admins_about_new_agenda
    admin_users = User.joins(:professional).where(professionals: { id: Professional.joins(:groups).where(groups: { is_admin: true }) })

    admin_users.each do |admin|
      AgendaNotificationMailer.admin_new_agenda(admin, self).deliver_later
    end
  end

  def notify_admins_about_conflicts(conflicts)
    admin_users = User.joins(:professional).where(professionals: { id: Professional.joins(:groups).where(groups: { is_admin: true }) })

    admin_users.each do |admin|
      AgendaNotificationMailer.admin_conflicts_detected(admin, self, conflicts).deliver_later
    end
  end

  def needs_maintenance?
    last_updated = updated_at
    last_updated < 30.days.ago
  end

  def inactive_for_too_long?
    return false unless active?

    last_event = events.order(:start_time).last
    return false unless last_event

    last_event.start_time < 60.days.ago
  end
end
