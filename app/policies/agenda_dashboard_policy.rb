class AgendaDashboardPolicy < ApplicationPolicy
  def view?
    user.can_view_agenda_dashboard?
  end

  def export?
    user.can_export_agenda_data?
  end

  def manage_alerts?
    user.can_manage_agenda_alerts?
  end
end
