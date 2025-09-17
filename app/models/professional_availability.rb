class ProfessionalAvailability < ApplicationRecord
  belongs_to :professional, class_name: 'Professional'
  belongs_to :agenda, optional: true

  enum :day_of_week, {
    monday: 0, tuesday: 1, wednesday: 2, thursday: 3,
    friday: 4, saturday: 5, sunday: 6
  }

  validates :start_time, :end_time, presence: true
  validates :day_of_week, presence: true
  validate :end_time_after_start_time

  scope :for_day, ->(day) { where(day_of_week: day) }
  scope :active, -> { where(active: true) }

  def duration_minutes
    return 0 if start_time.blank? || end_time.blank?

    start_minutes = (start_time.hour * 60) + start_time.min
    end_minutes = (end_time.hour * 60) + end_time.min

    end_minutes - start_minutes
  end

  def overlaps_with?(other_availability)
    return false if other_availability.id == id

    start_time < other_availability.end_time && end_time > other_availability.start_time
  end

  def covers_time?(time)
    time >= start_time && time < end_time
  end

  def time_slots(duration_minutes = 50, buffer_minutes = 10)
    slots = []
    current_time = start_time

    while current_time + duration_minutes.minutes <= end_time
      slot_end = current_time + duration_minutes.minutes

      slots << {
        start_time: current_time,
        end_time: slot_end,
        duration_minutes: duration_minutes
      }

      current_time = slot_end + buffer_minutes.minutes
    end

    slots
  end

  private

  def end_time_after_start_time
    return if start_time.blank? || end_time.blank?
    return unless end_time <= start_time

    errors.add(:end_time, 'deve ser posterior ao horário de início')
  end
end
