# frozen_string_literal: true

class ScheduledNotificationJob < ApplicationJob
  queue_as :notifications

  def perform
    NotificationService.process_scheduled_notifications
  end
end
