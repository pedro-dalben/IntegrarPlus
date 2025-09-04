class DashboardCalendarComponent < ViewComponent::Base
  include EventsHelper

  def initialize(events: [], professional: nil, view_type: 'month', read_only: true)
    @events = events
    @professional = professional
    @view_type = view_type
    @read_only = read_only
  end

  private

  attr_reader :events, :professional, :view_type, :read_only

  def calendar_id
    if professional
      "dashboard-calendar-professional-#{professional.id}"
    else
      'dashboard-calendar-main'
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
      height: '600px',
      events: events_url,
      eventClick: 'handleDashboardEventClick',
      eventDidMount: 'handleDashboardEventDidMount',
      selectable: !read_only,
      select: 'handleDashboardDateSelect',
      editable: !read_only,
      eventDrop: 'handleDashboardEventDrop',
      eventResize: 'handleDashboardEventResize',
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
      }
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

  def visibility_badge_class(visibility_level)
    case visibility_level
    when 'personal_private' then 'bg-red-100 text-red-800 dark:bg-red-900/20 dark:text-red-300'
    when 'restricted' then 'bg-orange-100 text-orange-800 dark:bg-orange-900/20 dark:text-orange-300'
    when 'publicly_visible' then 'bg-green-100 text-green-800 dark:bg-green-900/20 dark:text-green-300'
    else 'bg-gray-100 text-gray-800 dark:bg-gray-900/20 dark:text-gray-300'
    end
  end
end
