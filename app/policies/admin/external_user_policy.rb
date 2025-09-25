# frozen_string_literal: true

module Admin
  class ExternalUserPolicy < ApplicationPolicy
    def index?
      user.is_a?(User) && user.permit?('external_users.index')
    end

    def show?
      user.is_a?(User) && user.permit?('external_users.show')
    end

    def create?
      user.is_a?(User) && user.permit?('external_users.create')
    end

    def update?
      user.is_a?(User) && user.permit?('external_users.update')
    end

    def destroy?
      user.is_a?(User) && user.permit?('external_users.destroy')
    end

    def activate?
      user.is_a?(User) && user.permit?('external_users.update')
    end

    def deactivate?
      user.is_a?(User) && user.permit?('external_users.update')
    end

    class Scope < Scope
      def resolve
        if user.is_a?(User) && user.permit?('external_users.index')
          scope.all
        else
          scope.none
        end
      end
    end
  end
end
