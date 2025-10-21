# frozen_string_literal: true

class ReminderJob < ApplicationJob
  queue_as :default

  def perform(appointment_id, reminder_type)
    appointment = MedicalAppointment.find(appointment_id)

    case reminder_type
    when '24h'
      MedicalAppointmentMailer.reminder_24h(appointment).deliver_now
    when '48h'
      MedicalAppointmentMailer.reminder_48h(appointment).deliver_now
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn "Appointment #{appointment_id} not found for reminder #{reminder_type}"
  end
end
