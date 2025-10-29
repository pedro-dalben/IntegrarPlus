# frozen_string_literal: true

class JourneyEvent < ApplicationRecord
  belongs_to :portal_intake

  validates :event_type, presence: true
  validates :metadata, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :by_event_type, ->(type) { where(event_type: type) }

  def event_description
    case event_type
    when 'created'
      'Entrada criada no portal'
    when 'scheduled_anamnesis'
      data = metadata['scheduled_on']
      "Anamnese agendada para #{Date.parse(data).strftime('%d/%m/%Y')}" if data
    when 'finished_anamnesis'
      'Anamnese concluída'
    when 'cancelled_anamnesis'
      'Anamnese cancelada'
    when 'rescheduled_anamnesis'
      'Anamnese reagendada'
    when 'status_changed'
      from = metadata['from']
      to = metadata['to']
      "Status alterado de #{from&.humanize} para #{to&.humanize}"
    else
      event_type.humanize
    end
  end

  def event_icon
    case event_type
    when 'created'
      'plus-circle'
    when 'scheduled_anamnesis'
      'calendar'
    when 'finished_anamnesis'
      'check-circle'
    when 'cancelled_anamnesis'
      'x-circle'
    when 'rescheduled_anamnesis'
      'calendar-days'
    when 'status_changed'
      'arrow-right'
    else
      'circle'
    end
  end

  def admin_name
    metadata['admin_name'] || 'Sistema'
  end

  def formatted_date
    created_at.strftime('%d/%m/%Y às %H:%M')
  end
end
