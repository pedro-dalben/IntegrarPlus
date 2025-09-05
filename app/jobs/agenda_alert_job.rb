class AgendaAlertJob < ApplicationJob
  queue_as :default

  def perform(alert_type = :daily)
    case alert_type
    when :daily
      AgendaAlertService.send_daily_alerts
    when :weekly
      AgendaAlertService.send_weekly_summary
    when :check_only
      AgendaAlertService.check_alerts
    end
  end
end
