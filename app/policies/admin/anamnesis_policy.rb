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
      create?
    end

    def update?
      user.permit?('anamneses.update') && can_edit_anamnesis?
    end

    def edit?
      update?
    end

    def complete?
      user.permit?('anamneses.complete') && can_edit_anamnesis?
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
