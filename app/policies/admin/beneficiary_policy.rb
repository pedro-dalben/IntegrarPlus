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
      user.permit?('beneficiaries.new')
    end

    def update?
      user.permit?('beneficiaries.update')
    end

    def edit?
      user.permit?('beneficiaries.edit')
    end

    def destroy?
      user.permit?('beneficiaries.destroy')
    end

    def search?
      user.permit?('beneficiaries.search')
    end

    class Scope < Scope
      def resolve
        scope.all
      end
    end
  end
end
