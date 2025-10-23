# frozen_string_literal: true

class NotificationChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
    Rails.logger.info "User #{current_user.id} subscribed to notifications"
  end

  def unsubscribed
    Rails.logger.info "User #{current_user.id} unsubscribed from notifications"
  end

  def mark_as_read(data)
    notification = current_user.notifications.find(data['notification_id'])
    notification.mark_as_read!

    transmit({
               type: 'notification_read',
               notification_id: notification.id
             })
  rescue ActiveRecord::RecordNotFound
    transmit({
               type: 'error',
               message: 'Notification not found'
             })
  end

  def self.broadcast_notification(notification)
    broadcast_to(
      notification.user,
      {
        type: 'notification',
        id: notification.id,
        title: notification.title,
        message: notification.message,
        notification_type: notification.type,
        created_at: notification.created_at,
        icon: notification.type_icon,
        color: notification.type_color
      }
    )
  end

  def self.broadcast_notification_count(user)
    unread_count = user.notifications.unread.count

    broadcast_to(
      user,
      {
        type: 'notification_count',
        count: unread_count
      }
    )
  end
end
