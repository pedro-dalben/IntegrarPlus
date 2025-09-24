class AdvancedCalendarComponent < ViewComponent::Base
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
      "advanced-calendar-professional-#{professional.id}"
    else
      'advanced-calendar-main'
    end
  end

  def events_data
    return [] if events.empty?

    events.map do |event|
      {
        id: event.id,
        title: event.title,
        start: event.start_time.iso8601,
        end: event.end_time.iso8601,
        start_time: event.start_time.strftime('%H:%M'),
        end_time: event.end_time.strftime('%H:%M'),
        color: event_color(event.event_type),
        professional_name: event.professional&.full_name || 'N/A',
        event_type: event.event_type,
        description: event.description || ''
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

