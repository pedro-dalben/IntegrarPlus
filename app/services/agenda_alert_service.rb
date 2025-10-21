# frozen_string_literal: true

class AgendaAlertService
  def self.check_alerts
    alerts = []

    alerts += check_low_occupancy
    alerts += check_conflicts
    alerts += check_inactive_agendas
    alerts += check_maintenance_needed
    alerts += check_overloaded_professionals

    alerts
  end

  def self.check_low_occupancy
    alerts = []

    Agenda.active.each do |agenda|
      occupancy_rate = agenda.occupancy_rate

      if occupancy_rate < 30
        alerts << {
          type: :low_occupancy,
          severity: :medium,
          message: "Agenda '#{agenda.name}' com baixa ocupação (#{occupancy_rate}%)",
          agenda: agenda,
          actionable: true,
          action: 'Revisar horários e disponibilidade'
        }
      elsif occupancy_rate < 50
        alerts << {
          type: :moderate_occupancy,
          severity: :low,
          message: "Agenda '#{agenda.name}' com ocupação moderada (#{occupancy_rate}%)",
          agenda: agenda,
          actionable: false
        }
      end
    end

    alerts
  end

  def self.check_conflicts
    alerts = []

    Agenda.active.each do |agenda|
      next unless agenda.has_conflicts?

      conflicts = agenda.check_all_conflicts

      alerts << {
        type: :conflicts,
        severity: :high,
        message: "Agenda '#{agenda.name}' possui #{conflicts.count} conflitos de horário",
        agenda: agenda,
        conflicts: conflicts,
        actionable: true,
        action: 'Resolver conflitos de horário'
      }
    end

    alerts
  end

  def self.check_inactive_agendas
    alerts = []

    Agenda.active.each do |agenda|
      last_event = agenda.events.order(:start_time).last

      next unless last_event && last_event.start_time < 60.days.ago

      alerts << {
        type: :inactive_agenda,
        severity: :medium,
        message: "Agenda '#{agenda.name}' inativa há mais de 60 dias",
        agenda: agenda,
        last_event: last_event,
        actionable: true,
        action: 'Revisar necessidade da agenda'
      }
    end

    alerts
  end

  def self.check_maintenance_needed
    alerts = []

    Agenda.active.each do |agenda|
      next unless agenda.updated_at < 30.days.ago

      alerts << {
        type: :maintenance_needed,
        severity: :low,
        message: "Agenda '#{agenda.name}' não foi atualizada há mais de 30 dias",
        agenda: agenda,
        last_updated: agenda.updated_at,
        actionable: true,
        action: 'Revisar configurações da agenda'
      }
    end

    alerts
  end

  def self.check_overloaded_professionals
    alerts = []

    Professional.joins(:agenda_professionals).distinct.each do |professional|
      total_events = Event.where(professional: professional, start_time: 30.days.ago..Date.current).count
      total_slots = professional.agendas.active.sum { |agenda| agenda.calculate_total_slots(30.days.ago..Date.current) }

      utilization_rate = total_slots.zero? ? 0 : (total_events.to_f / total_slots * 100).round(2)

      if utilization_rate > 90
        alerts << {
          type: :overloaded_professional,
          severity: :high,
          message: "#{professional.name} com alta utilização (#{utilization_rate}%)",
          professional: professional,
          utilization_rate: utilization_rate,
          actionable: true,
          action: 'Revisar carga de trabalho'
        }
      elsif utilization_rate > 80
        alerts << {
          type: :high_utilization,
          severity: :medium,
          message: "#{professional.name} com utilização alta (#{utilization_rate}%)",
          professional: professional,
          utilization_rate: utilization_rate,
          actionable: true,
          action: 'Monitorar carga de trabalho'
        }
      end
    end

    alerts
  end

  def self.send_daily_alerts
    alerts = check_alerts
    send_alerts_by_priority(alerts)
    alerts
  end

  def self.send_alerts_by_priority(alerts)
    high_priority_alerts = alerts.select { |alert| alert[:severity] == :high }
    medium_priority_alerts = alerts.select { |alert| alert[:severity] == :medium }

    send_high_priority_alerts(high_priority_alerts) if high_priority_alerts.any?
    send_medium_priority_alerts(medium_priority_alerts) if medium_priority_alerts.any?
  end

  def self.send_weekly_summary
    alerts = check_alerts
    metrics = calculate_weekly_metrics

    admin_users = User.joins(:professional).where(professionals: { id: Professional.joins(:groups).where(groups: { is_admin: true }) })

    admin_users.each do |admin|
      NotificationService.send_weekly_summary(admin, alerts, metrics)
      AgendaNotificationMailer.weekly_summary(admin, alerts, metrics).deliver_later
    end
  end

  def self.send_high_priority_alerts(alerts)
    admin_users = User.joins(professional: :groups).where(groups: { is_admin: true }).distinct

    admin_users.each do |admin|
      AgendaNotificationMailer.high_priority_alerts(admin, alerts).deliver_later
    end
  end

  def self.send_medium_priority_alerts(alerts)
    admin_users = User.joins(professional: :groups).where(groups: { is_admin: true }).distinct

    admin_users.each do |admin|
      AgendaNotificationMailer.medium_priority_alerts(admin, alerts).deliver_later
    end
  end

  def self.calculate_weekly_metrics
    {
      total_agendas: Agenda.active.count,
      total_professionals: Professional.joins(:agenda_professionals).distinct.count,
      total_events: Event.where(start_time: 7.days.ago..Date.current).count,
      average_occupancy: calculate_average_occupancy,
      conflicts_count: Agenda.active.count(&:has_conflicts?),
      low_occupancy_count: Agenda.active.count { |a| a.occupancy_rate < 30 }
    }
  end

  def self.calculate_average_occupancy
    active_agendas = Agenda.active
    return 0 if active_agendas.empty?

    total_rate = active_agendas.sum(&:occupancy_rate)
    (total_rate / active_agendas.count).round(2)
  end
end
