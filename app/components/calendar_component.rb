# frozen_string_literal: true

class CalendarComponent < ViewComponent::Base
  include EventsHelper

  def initialize(events: [], professional: nil, view_type: 'week', read_only: false)
    @events = events
    @professional = professional
    @view_type = view_type
    @read_only = read_only
  end

  private

  attr_reader :events, :professional, :view_type, :read_only

  def calendar_id
    if professional
      "calendar-professional-#{professional.id}"
    else
      'calendar-personal'
    end
  end

  def events_url
    if professional
      "/professional_agendas/#{professional.id}/events_data"
    else
      '/admin/events/calendar_data'
    end
  end

  def calendar_options
    {
      initialView: view_type == 'month' ? 'dayGridMonth' : 'timeGridWeek',
      locale: 'pt-br',
      headerToolbar: {
        left: 'prev,next today',
        center: 'title',
        right: 'dayGridMonth,timeGridWeek,timeGridDay'
      },
      buttonText: {
        today: 'Hoje',
        month: 'Mês',
        week: 'Semana',
        day: 'Dia'
      },
      height: 'auto',
      events: events_url,
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
      firstDay: 1
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

  def visibility_scopes
    Event.visibility_levels.keys.map do |scope|
      {
        value: scope,
        label: scope.humanize
      }
    end
  end

  def visibility_badge_class(visibility_level)
    helpers.visibility_badge_class(visibility_level)
  end

  def event_color(event_type)
    case event_type
    when 'personal'
      '#3b82f6'
    when 'consulta'
      '#10b981'
    when 'atendimento'
      '#f59e0b'
    when 'reuniao'
      '#8b5cf6'
    when 'outro'
      '#6b7280'
    else
      '#3b82f6'
    end
  end
end
