# frozen_string_literal: true

class NotificationDeliveryJob < ApplicationJob
  queue_as :notifications

  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(notification_id)
    notification = Notification.find(notification_id)
    NotificationService.deliver(notification)
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn "Notification #{notification_id} not found"
  rescue StandardError => e
    Rails.logger.error "Failed to deliver notification #{notification_id}: #{e.message}"
    raise e
  end
end
