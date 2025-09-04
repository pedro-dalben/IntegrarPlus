# frozen_string_literal: true

class EventFormComponent < ViewComponent::Base
  def initialize(event: nil, professional: nil)
    @event = event
    @professional = professional
  end

  private

  attr_reader :event, :professional

  def form_title
    event&.persisted? ? 'Editar Evento' : 'Novo Evento'
  end

  def submit_text
    event&.persisted? ? 'Atualizar' : 'Criar'
  end

  def form_url
    if event&.persisted?
      "/admin/events/#{event.id}"
    else
      '/admin/events'
    end
  end

  def form_method
    event&.persisted? ? :patch : :post
  end

  def event_types
    Event.event_types.keys.map do |type|
      { value: type, label: type.humanize, color: event_color(type) }
    end
  end

  def visibility_levels
    Event.visibility_levels.keys.map do |level|
      { value: level, label: level.humanize }
    end
  end

  def event_color(event_type)
    case event_type
    when 'personal' then '#3b82f6'
    when 'consulta' then '#10b981'
    when 'atendimento' then '#f59e0b'
    when 'reuniao' then '#8b5cf6'
    when 'outro' then '#6b7280'
    else '#3b82f6'
    end
  end

  def default_start_time
    event&.start_time || (Time.current.beginning_of_hour + 1.hour)
  end

  def default_end_time
    event&.end_time || (default_start_time + 1.hour)
  end
end
