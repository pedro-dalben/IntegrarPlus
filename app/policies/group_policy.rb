# frozen_string_literal: true

class GroupPolicy < ApplicationPolicy
  def index?
    user.permit?('groups.manage')
  end

  def show?
    user.permit?('groups.manage')
  end

  def create?
    user.permit?('groups.manage')
  end

  def update?
    user.permit?('groups.manage')
  end

  def destroy?
    user.permit?('groups.manage')
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
