class SpecializationPolicy < ApplicationPolicy
  def index?
    user.permit?('settings.read')
  end

  def show?
    user.permit?('settings.read')
  end

  def create?
    user.permit?('settings.read')
  end

  def update?
    user.permit?('settings.read')
  end

  def destroy?
    user.permit?('settings.read')
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
