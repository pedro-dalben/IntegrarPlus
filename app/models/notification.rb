# frozen_string_literal: true

class Notification < ApplicationRecord
  self.inheritance_column = nil

  belongs_to :user

  enum :type, {
    agenda_created: 'agenda_created',
    agenda_updated: 'agenda_updated',
    appointment_scheduled: 'appointment_scheduled',
    appointment_reminder: 'appointment_reminder',
    appointment_cancelled: 'appointment_cancelled',
    appointment_rescheduled: 'appointment_rescheduled',
    appointment_completed: 'appointment_completed',
    appointment_no_show: 'appointment_no_show',
    conflict_detected: 'conflict_detected',
    low_occupancy: 'low_occupancy',
    emergency_alert: 'emergency_alert',
    daily_report: 'daily_report',
    weekly_report: 'weekly_report',
    monthly_report: 'monthly_report'
  }

  enum :status, {
    pending: 'pending',
    sent: 'sent',
    failed: 'failed',
    cancelled: 'cancelled'
  }

  enum :channel, {
    email: 'email',
    sms: 'sms',
    push: 'push',
    in_app: 'in_app'
  }

  validates :type, presence: true
  validates :title, presence: true
  validates :message, presence: true
  validates :channel, presence: true

  scope :unread, -> { where(read: false) }
  scope :read, -> { where(read: true) }
  scope :scheduled, -> { where.not(scheduled_at: nil) }
  scope :by_type, ->(type) { where(type: type) }
  scope :by_channel, ->(channel) { where(channel: channel) }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_user, ->(user) { where(user: user) }

  def mark_as_read!
    update!(read: true, read_at: Time.current)
  end

  def mark_as_unread!
    update!(read: false, read_at: nil)
  end

  def send_now!
    NotificationService.deliver(self)
  end

  def can_be_sent?
    pending? && (scheduled_at.nil? || scheduled_at <= Time.current)
  end

  def is_overdue?
    scheduled_at.present? && scheduled_at < Time.current && pending?
  end

  def formatted_created_at
    created_at.strftime('%d/%m/%Y às %H:%M')
  end

  def formatted_scheduled_at
    return nil unless scheduled_at

    scheduled_at.strftime('%d/%m/%Y às %H:%M')
  end

  def type_icon
    case type
    when 'agenda_created', 'agenda_updated'
      'calendar'
    when 'appointment_scheduled', 'appointment_reminder', 'appointment_cancelled', 'appointment_rescheduled', 'appointment_completed', 'appointment_no_show'
      'clock'
    when 'conflict_detected', 'emergency_alert'
      'alert-triangle'
    when 'low_occupancy'
      'trending-down'
    when 'daily_report', 'weekly_report', 'monthly_report'
      'file-text'
    else
      'bell'
    end
  end

  def type_color
    case type
    when 'agenda_created', 'agenda_updated'
      'success'
    when 'appointment_scheduled', 'appointment_reminder', 'appointment_completed'
      'info'
    when 'appointment_cancelled', 'appointment_no_show'
      'warning'
    when 'conflict_detected', 'emergency_alert'
      'danger'
    when 'low_occupancy'
      'warning'
    when 'daily_report', 'weekly_report', 'monthly_report'
      'primary'
    else
      'secondary'
    end
  end

  def channel_icon
    case channel
    when 'email'
      'mail'
    when 'sms'
      'message-square'
    when 'push'
      'smartphone'
    when 'in_app'
      'bell'
    else
      'bell'
    end
  end
end
