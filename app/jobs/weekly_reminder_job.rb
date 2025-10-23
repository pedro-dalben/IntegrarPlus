# frozen_string_literal: true

class WeeklyReminderJob < ApplicationJob
  queue_as :default

  def perform
    MedicalAppointmentService.send_weekly_reminders
    MedicalAppointmentService.send_weekly_schedules
  end
end
