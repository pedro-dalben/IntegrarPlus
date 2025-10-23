# frozen_string_literal: true

class EventsListComponent < ViewComponent::Base
  def initialize(events: [], professional: nil)
    @events = events
    @professional = professional
  end

  private

  attr_reader :events, :professional

  def events_by_date
    events.group_by { |event| event.start_time.to_date }
  end

  def format_time(event)
    "#{event.start_time.strftime('%H:%M')} - #{event.end_time.strftime('%H:%M')}"
  end

  def format_date(date)
    date.strftime('%A, %d de %B')
  end

  def event_badge_class(event_type)
    case event_type
    when 'personal' then 'bg-blue-100 text-blue-800 dark:bg-blue-900/20 dark:text-blue-300'
    when 'consulta' then 'bg-green-100 text-green-800 dark:bg-green-900/20 dark:text-green-300'
    when 'atendimento' then 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/20 dark:text-yellow-300'
    when 'reuniao' then 'bg-purple-100 text-purple-800 dark:bg-purple-900/20 dark:text-purple-300'
    when 'outro' then 'bg-gray-100 text-gray-800 dark:bg-gray-900/20 dark:text-gray-300'
    else 'bg-gray-100 text-gray-800 dark:bg-gray-900/20 dark:text-gray-300'
    end
  end

  def visibility_badge_class(visibility_level)
    case visibility_level
    when 'personal_private' then 'bg-red-100 text-red-800 dark:bg-red-900/20 dark:text-red-300'
    when 'restricted' then 'bg-orange-100 text-orange-800 dark:bg-orange-900/20 dark:text-orange-300'
    when 'publicly_visible' then 'bg-green-100 text-green-800 dark:bg-green-900/20 dark:text-green-300'
    else 'bg-gray-100 text-gray-800 dark:bg-gray-900/20 dark:text-gray-300'
    end
  end

  def can_edit_event?(_event)
    return true if professional.nil?
    return true if current_user&.professional&.id == professional.id

    current_user&.permit?(:manage_events)
  end

  def current_user
    @current_user ||= defined?(current_user) ? current_user : nil
  end
end
