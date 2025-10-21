# frozen_string_literal: true

class MedicalAppointmentPolicy < ApplicationPolicy
  def index?
    user.can_view_medical_appointments?
  end

  def show?
    user.can_view_medical_appointments? || user.can_access_appointment?(record)
  end

  def create?
    user.can_create_medical_appointments?
  end

  def update?
    user.can_update_medical_appointments? || user.can_edit_appointment?(record)
  end

  def destroy?
    user.can_delete_medical_appointments?
  end

  def cancel?
    user.can_cancel_medical_appointments? || user.can_cancel_appointment?(record)
  end

  def reschedule?
    user.can_reschedule_medical_appointments? || user.can_edit_appointment?(record)
  end

  def complete?
    user.can_complete_medical_appointments? || user.can_complete_appointment?(record)
  end

  def mark_no_show?
    user.can_mark_no_show_medical_appointments? || user.can_complete_appointment?(record)
  end

  def reports?
    user.can_view_medical_appointment_reports?
  end

  def professional_report?
    user.can_view_medical_appointment_reports? || record.professional == user
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.permit?('medical_appointments.read')
        scope.all
      else
        scope.where(professional: user).or(scope.where(patient: user))
      end
    end
  end
end
