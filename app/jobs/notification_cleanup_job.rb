# frozen_string_literal: true

class NotificationCleanupJob < ApplicationJob
  queue_as :low_priority

  def perform(days = 30)
    NotificationService.cleanup_old_notifications(days)
  end
end
