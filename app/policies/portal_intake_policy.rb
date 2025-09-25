# frozen_string_literal: true

class PortalIntakePolicy < ApplicationPolicy
  def index?
    user.is_a?(ExternalUser) && user.active?
  end

  def show?
    user.is_a?(ExternalUser) && user.active? && record.operator == user
  end

  def create?
    return false unless user.is_a?(ExternalUser)
    return false unless user.active?

    true
  end

  def new?
    create?
  end

  class Scope < Scope
    def resolve
      if user.is_a?(ExternalUser)
        scope.where(operator: user)
      else
        scope.none
      end
    end
  end
end
