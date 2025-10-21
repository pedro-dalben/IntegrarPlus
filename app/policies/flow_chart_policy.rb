class FlowChartPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.admin? || user.permit?('flow_charts.manage')
  end

  def update?
    user.admin? || user.permit?('flow_charts.manage')
  end

  def destroy?
    user.admin? || user.permit?('flow_charts.manage')
  end

  def publish?
    user.admin? || user.permit?('flow_charts.manage')
  end

  def duplicate?
    user.admin? || user.permit?('flow_charts.manage')
  end

  def export_pdf?
    true
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
