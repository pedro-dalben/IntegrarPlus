# frozen_string_literal: true

class AvailabilityException < ApplicationRecord
  belongs_to :professional, class_name: 'Professional'
  belongs_to :agenda, optional: true

  enum :exception_type, {
    unavailable: 0,
    different_hours: 1,
    break: 2
  }

  validates :exception_date, presence: true
  validates :start_time, :end_time, presence: true, if: :different_hours?
  validate :end_time_after_start_time, if: :different_hours?
  validate :valid_exception_type

  scope :for_date, ->(date) { where(exception_date: date) }
  scope :active, -> { where(active: true) }
  scope :unavailable, -> { where(exception_type: :unavailable) }
  scope :different_hours, -> { where(exception_type: :different_hours) }
  scope :breaks, -> { where(exception_type: :break) }

  def affects_time?(time)
    return false unless active?
    return false unless time.to_date == exception_date

    case exception_type
    when 'unavailable'
      true
    when 'different_hours', 'break'
      time >= start_time && time < end_time
    else
      false
    end
  end

  def blocks_time?(time)
    return false unless active?
    return false unless time.to_date == exception_date

    case exception_type
    when 'unavailable'
      true
    when 'break'
      time >= start_time && time < end_time
    else
      false
    end
  end

  def alternative_hours?(time)
    return false unless active?
    return false unless different_hours?
    return false unless time.to_date == exception_date

    time >= start_time && time < end_time
  end

  def description
    case exception_type
    when 'unavailable'
      "Indisponível em #{exception_date.strftime('%d/%m/%Y')}"
    when 'different_hours'
      "Horário diferente em #{exception_date.strftime('%d/%m/%Y')}: #{start_time.strftime('%H:%M')} - #{end_time.strftime('%H:%M')}"
    when 'break'
      "Pausa em #{exception_date.strftime('%d/%m/%Y')}: #{start_time.strftime('%H:%M')} - #{end_time.strftime('%H:%M')}"
    end
  end

  private

  def end_time_after_start_time
    return if start_time.blank? || end_time.blank?
    return unless end_time <= start_time

    errors.add(:end_time, 'deve ser posterior ao horário de início')
  end

  def valid_exception_type
    return if exception_type.present?

    errors.add(:exception_type, 'deve ser especificado')
  end
end
