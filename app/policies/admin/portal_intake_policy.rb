# frozen_string_literal: true

module Admin
  class PortalIntakePolicy < ApplicationPolicy
    def index?
      user.is_a?(User) && user.permit?('portal_intakes.index')
    end

    def show?
      user.is_a?(User) && user.permit?('portal_intakes.show')
    end

    def new?
      user.is_a?(User) && user.permit?('portal_intakes.create')
    end

    def create?
      new?
    end

    def schedule_anamnesis?
      user.is_a?(User) && user.permit?('portal_intakes.schedule_anamnesis')
    end

    def reschedule_anamnesis?
      user.is_a?(User) && user.permit?('portal_intakes.schedule_anamnesis')
    end

    def agenda_view?
      schedule_anamnesis?
    end

    def check_slot_availability?
      schedule_anamnesis?
    end

    def cancel_anamnesis?
      user.is_a?(User) && user.permit?('portal_intakes.schedule_anamnesis')
    end

    def update?
      user.is_a?(User) && user.permit?('portal_intakes.update')
    end

    class Scope < Scope
      def resolve
        if user.is_a?(User) && user.permit?('portal_intakes.index')
          scope.all
        else
          scope.none
        end
      end
    end
  end
end
