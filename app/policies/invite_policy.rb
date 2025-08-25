# frozen_string_literal: true

class InvitePolicy < ApplicationPolicy
  def index?
    user.permit?('invites.index')
  end

  def show?
    user.permit?('invites.show')
  end

  def create?
    user.permit?('invites.create')
  end

  def update?
    user.permit?('invites.update')
  end

  def destroy?
    user.permit?('invites.destroy')
  end

  def resend?
    user.permit?('invites.resend')
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
