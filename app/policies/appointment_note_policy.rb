class AppointmentNotePolicy < ApplicationPolicy
  def index?
    user.admin? || user.permit?('appointment_notes.read')
  end

  def show?
    user.admin? || user.permit?('appointment_notes.read') ||
    (record.medical_appointment.professional == user) || (record.medical_appointment.patient == user)
  end

  def create?
    user.admin? || user.permit?('appointment_notes.create')
  end

  def update?
    user.admin? || user.permit?('appointment_notes.update') || record.created_by == user
  end

  def destroy?
    user.admin? || user.permit?('appointment_notes.delete') || record.created_by == user
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.permit?('appointment_notes.read')
        scope.all
      else
        scope.joins(:medical_appointment).where(
          medical_appointments: { professional: user }
        ).or(
          scope.joins(:medical_appointment).where(
            medical_appointments: { patient: user }
          )
        )
      end
    end
  end
end
