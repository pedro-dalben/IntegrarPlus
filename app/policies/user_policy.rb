class UserPolicy < ApplicationPolicy
  def index?
    user.permit?('users.index')
  end

  def show?
    user.permit?('users.show')
  end

  def create?
    user.permit?('users.create')
  end

  def update?
    user.permit?('users.update')
  end

  def destroy?
    user.permit?('users.destroy')
  end

  def activate?
    user.permit?('users.activate')
  end

  def deactivate?
    user.permit?('users.deactivate')
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.none
      end
    end
  end
end
