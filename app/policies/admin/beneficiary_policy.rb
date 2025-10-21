# frozen_string_literal: true

module Admin
  class BeneficiaryPolicy < ApplicationPolicy
    def index?
      user.permit?('beneficiaries.index')
    end

    def show?
      user.permit?('beneficiaries.show')
    end

    def create?
      user.permit?('beneficiaries.create')
    end

    def new?
      create?
    end

    def update?
      user.permit?('beneficiaries.update')
    end

    def edit?
      update?
    end

    def destroy?
      user.permit?('beneficiaries.destroy')
    end

    class Scope < Scope
      def resolve
        if user.admin?
        end
        scope.all
      end
    end
  end
end
