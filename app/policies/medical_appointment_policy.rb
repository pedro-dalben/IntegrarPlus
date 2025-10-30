# frozen_string_literal: true

class MedicalAppointmentPolicy < ApplicationPolicy
  def index?
    user.admin? || user.secretary?
  end

  def show?
    user.admin? || user.secretary?
  end

  def create?
    user.admin? || user.secretary?
  end

  def update?
    user.admin? || user.secretary?
  end

  def destroy?
    user.admin? || user.secretary?
  end

  def cancel?
    user.admin? || user.secretary?
  end

  def reschedule?
    user.admin? || user.secretary?
  end

  def complete?
    user.admin? || user.secretary?
  end

  def mark_no_show?
    user.admin? || user.secretary?
  end

  def reports?
    user.admin? || user.secretary?
  end

  def professional_report?
    user.admin? || user.secretary?
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
