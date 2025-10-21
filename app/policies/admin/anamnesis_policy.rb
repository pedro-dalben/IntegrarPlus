# frozen_string_literal: true

module Admin
  class AnamnesisPolicy < ApplicationPolicy
    def index?
      user.permit?('anamneses.index')
    end

    def show?
      user.permit?('anamneses.show') && can_view_anamnesis?
    end

    def create?
      user.permit?('anamneses.create')
    end

    def new?
      user.permit?('anamneses.new')
    end

    def update?
      user.permit?('anamneses.update') && can_edit_anamnesis?
    end

    def edit?
      user.permit?('anamneses.edit')
    end

    def complete?
      user.permit?('anamneses.complete') && can_edit_anamnesis?
    end

    def today?
      user.permit?('anamneses.today')
    end

    def by_professional?
      user.permit?('anamneses.by_professional')
    end

    class Scope < Scope
      def resolve
        if user.permit?('anamneses.view_all')
          scope.all
        else
          scope.by_professional(user.professional)
        end
      end
    end

    private

    def can_view_anamnesis?
      return true if user.permit?('anamneses.view_all')
      return true if record.professional == user.professional
a
      false
    end

    def can_edit_anamnesis?
      return false unless record.pode_ser_editada?

      return true if user.permit?('anamneses.view_all')
      return true if record.professional == user.professional

      false
    end
  end
end
