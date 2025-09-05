module UserPermissions
  extend ActiveSupport::Concern

  def can_access_appointment?(appointment)
    return true if admin?
    return true if appointment.professional == self
    return true if appointment.patient == self
    false
  end

  def can_edit_appointment?(appointment)
    return true if admin?
    return true if appointment.professional == self
    return true if appointment.patient == self
    false
  end

  def can_cancel_appointment?(appointment)
    return true if admin?
    return true if appointment.professional == self
    return true if appointment.patient == self
    false
  end

  def can_complete_appointment?(appointment)
    return true if admin?
    return true if appointment.professional == self
    false
  end

  def can_view_agenda_dashboard?
    admin? || permit?('agenda_dashboard.view')
  end

  def can_export_agenda_data?
    admin? || permit?('agenda_dashboard.export')
  end

  def can_manage_agenda_alerts?
    admin? || permit?('agenda_dashboard.manage_alerts')
  end

  def can_manage_medical_appointments?
    admin? || permit?('medical_appointments.manage')
  end

  def can_view_medical_appointments?
    admin? || permit?('medical_appointments.read')
  end

  def can_create_medical_appointments?
    admin? || permit?('medical_appointments.create')
  end

  def can_update_medical_appointments?
    admin? || permit?('medical_appointments.update')
  end

  def can_delete_medical_appointments?
    admin? || permit?('medical_appointments.delete')
  end

  def can_cancel_medical_appointments?
    admin? || permit?('medical_appointments.cancel')
  end

  def can_reschedule_medical_appointments?
    admin? || permit?('medical_appointments.reschedule')
  end

  def can_complete_medical_appointments?
    admin? || permit?('medical_appointments.complete')
  end

  def can_mark_no_show_medical_appointments?
    admin? || permit?('medical_appointments.mark_no_show')
  end

  def can_view_medical_appointment_reports?
    admin? || permit?('medical_appointments.reports')
  end
end
