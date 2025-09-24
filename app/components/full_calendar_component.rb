class FullCalendarComponent < ViewComponent::Base
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
      "full-calendar-professional-#{professional.id}"
    else
      'full-calendar-main'
    end
  end

  def events_data
    return [].to_json if events.empty?

    events.map do |event|
      {
        id: event.id,
        title: event.title,
        start: event.start_time.iso8601,
        end: event.end_time.iso8601,
        color: event_color(event.event_type),
        extendedProps: {
          event_type: event.event_type,
          professional_name: event.professional&.full_name || 'N/A',
          description: event.description || '',
          visibility_level: event.visibility_level
        }
      }
    end.to_json
  end

  def calendar_options
    {
      initialView: 'dayGridMonth',
      locale: 'pt-br',
      headerToolbar: {
        left: 'prev,next today',
        center: 'title',
        right: 'dayGridMonth,timeGridWeek,timeGridDay,listWeek'
      },
      buttonText: {
        today: 'Hoje',
        month: 'Mês',
        week: 'Semana',
        day: 'Dia',
        list: 'Lista'
      },
      height: 'auto',
      events: events_data,
      eventClick: 'handleEventClick',
      eventDidMount: 'handleEventDidMount',
      selectable: !read_only,
      select: 'handleDateSelect',
      editable: !read_only,
      eventDrop: 'handleEventDrop',
      eventResize: 'handleEventResize',
      slotMinTime: '07:00:00',
      slotMaxTime: '20:00:00',
      allDaySlot: false,
      slotDuration: '00:30:00',
      slotLabelInterval: '01:00:00',
      dayHeaderFormat: { weekday: 'long' },
      firstDay: 1,
      eventDisplay: 'block',
      eventTimeFormat: {
        hour: '2-digit',
        minute: '2-digit',
        meridiem: false
      },
      businessHours: {
        daysOfWeek: [1, 2, 3, 4, 5],
        startTime: '08:00',
        endTime: '18:00'
      },
      nowIndicator: true,
      scrollTime: '08:00:00'
    }.to_json
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
