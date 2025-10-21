# frozen_string_literal: true

class SimpleCalendarComponent < ViewComponent::Base
  include EventsHelper

  def initialize(events: [], professional: nil, read_only: false)
    @events = events
    @professional = professional
    @read_only = read_only
  end

  private

  attr_reader :events, :professional, :read_only

  def calendar_id
    if professional
      "simple-calendar-professional-#{professional.id}"
    else
      'simple-calendar-main'
    end
  end

  def events_data
    return [] if events.empty?

    events.map do |event|
      {
        id: event.id,
        title: event.title,
        start: event.start_time.strftime('%Y-%m-%d %H:%M'),
        end: event.end_time.strftime('%Y-%m-%d %H:%M'),
        color: event_color(event.event_type),
        professional_name: event.professional&.full_name || 'N/A',
        event_type: event.event_type
      }
    end
  end

  def event_types
    Event.event_types.keys.map do |type|
      {
        value: type,
        label: type.humanize,
        color: event_color(type)
      }
    end
  end
end
