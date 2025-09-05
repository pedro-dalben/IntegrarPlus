class AppointmentReminderJob < ApplicationJob
  queue_as :notifications
  
  def perform(appointment_id, reminder_type)
    appointment = MedicalAppointment.find(appointment_id)
    
    return if appointment.cancelled? || appointment.completed?
    
    NotificationService.schedule_reminder(appointment, reminder_type)
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn "Appointment #{appointment_id} not found for reminder"
  end
end
