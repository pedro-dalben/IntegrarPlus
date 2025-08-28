# frozen_string_literal: true

class ServiceRequestPolicy < ApplicationPolicy
  def index?
    user.is_a?(ExternalUser) && user.active?
  end

  def show?
    user.is_a?(ExternalUser) && user.active? && record.external_user == user
  end

  def create?
    user.is_a?(ExternalUser) && user.active?
  end

  def new?
    create?
  end

  def update?
    user.is_a?(ExternalUser) && user.active? && record.external_user == user && record.status == 'aguardando'
  end

  def edit?
    update?
  end

  def destroy?
    user.is_a?(ExternalUser) && user.active? && record.external_user == user && record.status == 'aguardando'
  end

  class Scope < Scope
    def resolve
      if user.is_a?(ExternalUser)
        scope.where(external_user: user)
      else
        scope.none
      end
    end
  end
end
