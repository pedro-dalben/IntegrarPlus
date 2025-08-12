class ProfessionalPolicy < ApplicationPolicy
  def index?
    user.permit?('professionals.read')
  end

  def show?
    user.permit?('professionals.read')
  end

  def create?
    user.permit?('professionals.manage')
  end

  def update?
    user.permit?('professionals.manage')
  end

  def destroy?
    user.permit?('professionals.manage')
  end

  def manage?
    user.permit?('professionals.manage')
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
