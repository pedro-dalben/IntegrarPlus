class AppointmentAttachmentPolicy < ApplicationPolicy
  def index?
    user.admin? || user.permit?('appointment_attachments.read')
  end

  def show?
    user.admin? || user.permit?('appointment_attachments.read') ||
    (record.medical_appointment.professional == user) || (record.medical_appointment.patient == user)
  end

  def create?
    user.admin? || user.permit?('appointment_attachments.create')
  end

  def download?
    user.admin? || user.permit?('appointment_attachments.download') ||
    (record.medical_appointment.professional == user) || (record.medical_appointment.patient == user)
  end

  def update?
    user.admin? || user.permit?('appointment_attachments.update') || record.uploaded_by == user
  end

  def destroy?
    user.admin? || user.permit?('appointment_attachments.delete') || record.uploaded_by == user
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.permit?('appointment_attachments.read')
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
