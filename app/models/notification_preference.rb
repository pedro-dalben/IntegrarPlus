# frozen_string_literal: true

class NotificationPreference < ApplicationRecord
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

  validates :user_id, uniqueness: { scope: :type }
  validates :type, presence: true

  scope :enabled, -> { where(email_enabled: true).or(where(sms_enabled: true)).or(where(push_enabled: true)) }
  scope :by_type, ->(type) { where(type: type) }
  scope :for_user, ->(user) { where(user: user) }

  def enabled_channels
    channels = []
    channels << 'email' if email_enabled
    channels << 'sms' if sms_enabled
    channels << 'push' if push_enabled
    channels
  end

  def has_enabled_channels?
    enabled_channels.any?
  end

  def channel_enabled?(channel)
    case channel
    when 'email' then email_enabled
    when 'sms' then sms_enabled
    when 'push' then push_enabled
    else false
    end
  end

  def enable_channel(channel)
    case channel
    when 'email' then update!(email_enabled: true)
    when 'sms' then update!(sms_enabled: true)
    when 'push' then update!(push_enabled: true)
    end
  end

  def disable_channel(channel)
    case channel
    when 'email' then update!(email_enabled: false)
    when 'sms' then update!(sms_enabled: false)
    when 'push' then update!(push_enabled: false)
    end
  end

  def self.create_default_preferences_for_user(user)
    types = NotificationPreference.types.keys

    types.each do |type|
      create!(
        user: user,
        type: type,
        email_enabled: default_email_enabled?(type),
        sms_enabled: default_sms_enabled?(type),
        push_enabled: default_push_enabled?(type)
      )
    end
  end

  def self.default_email_enabled?(type)
    case type
    when 'emergency_alert', 'conflict_detected'
      true
    when 'appointment_reminder', 'low_occupancy'
      false
    else
      true
    end
  end

  def self.default_sms_enabled?(type)
    case type
    when 'emergency_alert'
      true
    else
      false
    end
  end

  def self.default_push_enabled?(type)
    case type
    when 'appointment_reminder', 'emergency_alert', 'conflict_detected'
      true
    else
      false
    end
  end

  def self.get_preference(user, type)
    find_by(user: user, type: type) || create_default_preference(user, type)
  end

  def self.create_default_preference(user, type)
    create!(
      user: user,
      type: type,
      email_enabled: default_email_enabled?(type),
      sms_enabled: default_sms_enabled?(type),
      push_enabled: default_push_enabled?(type)
    )
  end
end
