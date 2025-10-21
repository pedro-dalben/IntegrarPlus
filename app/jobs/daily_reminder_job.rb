# frozen_string_literal: true

class DailyReminderJob < ApplicationJob
  queue_as :default

  def perform
    MedicalAppointmentService.send_daily_reminders
    MedicalAppointmentService.send_daily_schedules
    MedicalAppointmentService.check_emergency_appointments
    MedicalAppointmentService.check_overdue_appointments
  end
end
