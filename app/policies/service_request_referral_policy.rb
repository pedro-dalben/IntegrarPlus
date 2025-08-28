# frozen_string_literal: true

class ServiceRequestReferralPolicy < ApplicationPolicy
  def create?
    user.is_a?(ExternalUser) && user.active? && record.service_request.external_user == user && record.service_request.status == 'aguardando'
  end

  def destroy?
    user.is_a?(ExternalUser) && user.active? && record.service_request.external_user == user && record.service_request.status == 'aguardando'
  end

  class Scope < Scope
    def resolve
      if user.is_a?(ExternalUser)
        scope.joins(:service_request).where(service_requests: { external_user: user })
      else
        scope.none
      end
    end
  end
end
