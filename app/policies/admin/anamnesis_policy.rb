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

    def start?
      user.permit?('anamneses.start') && record.pode_ser_iniciada? && can_edit_anamnesis?
    end

    def complete?
      user.permit?('anamneses.complete') && can_edit_anamnesis?
    end

    def start?
      user.permit?('anamneses.edit') && record.pode_ser_iniciada? && can_act_on_anamnesis?
    end

    def mark_attended?
      user.permit?('anamneses.edit') && record.pode_marcar_comparecimento? && can_act_on_anamnesis?
    end

    def mark_no_show?
      user.permit?('anamneses.edit') && record.pode_marcar_comparecimento? && can_act_on_anamnesis?
    end

    def cancel_anamnesis?
      user.permit?('anamneses.edit') && can_act_on_anamnesis?
    end

    def reschedule_form?
      user.permit?('anamneses.edit') && can_act_on_anamnesis?
    end

    def reschedule?
      user.permit?('anamneses.edit') && can_act_on_anamnesis?
    end

    def today?
      user.permit?('anamneses.today')
    end

    def by_professional?
      user.permit?('anamneses.by_professional')
    end

    def print_pdf?
      user.permit?('anamneses.show') && can_view_anamnesis?
    end

    def mark_attended?
      user.permit?('anamneses.mark_attended') && can_manage_attendance?
    end

    def mark_no_show?
      user.permit?('anamneses.mark_no_show') && can_manage_attendance?
    end

    def cancel_anamnesis?
      user.permit?('anamneses.cancel_anamnesis') && can_edit_anamnesis?
    end

    def reschedule_form?
      user.permit?('anamneses.reschedule_form') && can_reschedule_anamnesis?
    end

    def reschedule?
      user.permit?('anamneses.reschedule') && can_reschedule_anamnesis?
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

    def can_act_on_anamnesis?
      return true if user.permit?('anamneses.view_all')
      return true if record.professional == user.professional

      false
    end

    def can_manage_attendance?
      can_edit_anamnesis? && record.pode_marcar_comparecimento?
    end

    def can_reschedule_anamnesis?
      can_edit_anamnesis? && record.pode_reagendar?
    end
  end
end
