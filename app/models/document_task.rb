# frozen_string_literal: true

class DocumentTask < ApplicationRecord
  belongs_to :document
  belongs_to :created_by, class_name: 'Professional', foreign_key: 'created_by_professional_id'
  belongs_to :assigned_to, class_name: 'Professional', foreign_key: 'assigned_to_professional_id', optional: true
  belongs_to :completed_by, class_name: 'Professional', foreign_key: 'completed_by_professional_id', optional: true

  enum :priority, {
    low: 0,
    medium: 1,
    high: 2
  }

  validates :title, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 1000 }
  validates :priority, presence: true

  scope :pending, -> { where(completed_at: nil) }
  scope :completed, -> { where.not(completed_at: nil) }
  scope :by_priority, -> { order(priority: :desc) }

  def completed?
    completed_at.present?
  end

  def complete!(professional)
    update!(
      completed_by: professional,
      completed_at: Time.current
    )
  end

  def reopen!
    update!(
      completed_by: nil,
      completed_at: nil
    )
  end

  def priority_color
    case priority
    when 'high'
      'text-red-600 bg-red-50 border-red-200'
    when 'medium'
      'text-yellow-600 bg-yellow-50 border-yellow-200'
    when 'low'
      'text-green-600 bg-green-50 border-green-200'
    end
  end

  def priority_icon
    case priority
    when 'high'
      '🔴'
    when 'medium'
      '🟡'
    when 'low'
      '🟢'
    end
  end
end
