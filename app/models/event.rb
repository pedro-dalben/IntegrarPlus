# frozen_string_literal: true

class Event < ApplicationRecord
  belongs_to :professional
  belongs_to :created_by, class_name: 'Professional'
  belongs_to :calendar, optional: true
  belongs_to :agenda, optional: true
  has_one :medical_appointment, dependent: :nullify

  enum :event_type, { personal: 0, consulta: 1, atendimento: 2, reuniao: 3, anamnese: 4, outro: 5 }
  enum :visibility_level, { personal_private: 0, restricted: 1, publicly_visible: 2 }
  enum :status, { active: 0, cancelled: 1, completed: 2 }

  validates :title, presence: true, length: { maximum: 255 }
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :event_type, presence: true
  validates :visibility_level, presence: true

  validate :end_time_after_start_time
  validate :no_time_conflicts, on: :create

  scope :for_professional, ->(professional_id) { where(professional_id: professional_id) }
  scope :in_time_range, ->(start_time, end_time) { where('start_time < ? AND end_time > ?', end_time, start_time) }
  scope :active_events, -> { where(status: :active) }
  scope :by_type, ->(type) { where(event_type: type) }
  scope :by_visibility, ->(level) { where(visibility_level: level) }

  scope :visible_for_professional, lambda { |viewing_professional, target_professional_id|
    if viewing_professional&.id == target_professional_id
      where(professional_id: target_professional_id)
    else
      where(professional_id: target_professional_id).where.not(visibility_level: :personal_private)
    end
  }

  scope :available_slots, lambda { |professional_id, start_time, end_time|
    where(professional_id: professional_id)
      .in_time_range(start_time, end_time)
      .active_events
  }

  def duration_minutes
    ((end_time - start_time) / 1.minute).to_i
  end

  def conflicts_with?(other_event)
    return false if other_event.id == id

    start_time < other_event.end_time && end_time > other_event.start_time
  end

  def visible_for_professional?(viewing_professional)
    return true if viewing_professional&.id == professional_id
    return false if visibility_level == 'personal_private'
    return true if visibility_level == 'publicly_visible'

    visibility_level == 'restricted' && viewing_professional&.permit?(:view_restricted_events)
  end

  def masked_for_institutional_view
    if visibility_level == 'publicly_visible'
      self
    else
      masked_event = dup
      masked_event.title = 'Ocupado'
      masked_event.description = nil
      masked_event
    end
  end

  def self.availability_for_professional(professional_id, start_time, end_time)
    conflicting_events = available_slots(professional_id, start_time, end_time)
    {
      professional_id: professional_id,
      start_time: start_time,
      end_time: end_time,
      available: conflicting_events.empty?,
      conflicting_events: conflicting_events.map(&:masked_for_institutional_view)
    }
  end

  def self.create_with_conflict_check(attributes)
    professional_id = attributes[:professional_id]
    start_time = attributes[:start_time]
    end_time = attributes[:end_time]

    conflicts = available_slots(professional_id, start_time, end_time)
    if conflicts.any?
      return { success: false, errors: ['Horário conflita com eventos existentes'], conflicts: conflicts }
    end

    event = create(attributes)
    if event.persisted?
      { success: true, event: event }
    else
      { success: false, errors: event.errors.full_messages }
    end
  end

  private

  def end_time_after_start_time
    return if start_time.blank? || end_time.blank?
    return unless end_time <= start_time

    errors.add(:end_time, 'deve ser posterior ao horário de início')
  end

  def no_time_conflicts
    return if start_time.blank? || end_time.blank? || professional_id.blank?

    conflicts = self.class.available_slots(professional_id, start_time, end_time)
    return unless conflicts.any?

    errors.add(:base, 'Horário conflita com eventos existentes')
  end
end
