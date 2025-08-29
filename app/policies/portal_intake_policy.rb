# frozen_string_literal: true

class PortalIntakePolicy < ApplicationPolicy
  def index?
    user.is_a?(ExternalUser) && user.active?
  end

  def show?
    user.is_a?(ExternalUser) && user.active? && record.operator == user
  end

  def create?
    user.is_a?(ExternalUser) && user.active?
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
