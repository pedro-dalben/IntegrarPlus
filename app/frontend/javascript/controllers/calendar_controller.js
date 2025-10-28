import { Controller } from '@hotwired/stimulus';
import { Calendar } from '@fullcalendar/core';
import dayGridPlugin from '@fullcalendar/daygrid';
import timeGridPlugin from '@fullcalendar/timegrid';
import interactionPlugin from '@fullcalendar/interaction';
import listPlugin from '@fullcalendar/list';
import ptBrLocale from '@fullcalendar/core/locales/pt-br';

export default class extends Controller {
  static targets = ['calendar', 'viewSelector', 'eventTypeFilter'];
  static values = {
    eventsUrl: String,
    readOnly: Boolean,
    professionalId: Number,
  };

  connect() {
    this.initializeCalendar();
    this.setupEventListeners();
  }

  disconnect() {
    if (this.calendar) {
      this.calendar.destroy();
    }
  }

  initializeCalendar() {
    const calendarEl = this.calendarTarget;

    this.calendar = new Calendar(calendarEl, {
      plugins: [dayGridPlugin, timeGridPlugin, interactionPlugin, listPlugin],
      locale: ptBrLocale,
      initialView: 'timeGridWeek',
      headerToolbar: {
        left: 'prev,next today',
        center: 'title',
        right: 'dayGridMonth,timeGridWeek,timeGridDay,listWeek',
      },
      buttonText: {
        today: 'Hoje',
        month: 'Mês',
        week: 'Semana',
        day: 'Dia',
        list: 'Lista',
      },
      height: 'auto',
      events: this.eventsUrlValue,
      eventClick: this.handleEventClick.bind(this),
      eventDidMount: this.handleEventDidMount.bind(this),
      selectable: !this.readOnlyValue,
      select: this.handleDateSelect.bind(this),
      editable: !this.readOnlyValue,
      eventDrop: this.handleEventDrop.bind(this),
      eventResize: this.handleEventResize.bind(this),
      slotMinTime: '07:00:00',
      slotMaxTime: '20:00:00',
      allDaySlot: false,
      slotDuration: '00:30:00',
      slotLabelInterval: '01:00:00',
      dayHeaderFormat: { weekday: 'long' },
      firstDay: 1,
      selectMirror: true,
      dayMaxEvents: true,
      weekends: true,
      businessHours: {
        daysOfWeek: [1, 2, 3, 4, 5],
        startTime: '08:00',
        endTime: '18:00',
      },
    });

    this.calendar.render();
  }

  setupEventListeners() {
    if (this.hasViewSelectorTarget) {
      this.viewSelectorTarget.addEventListener('change', e => {
        this.calendar.changeView(e.target.value);
      });
    }

    if (this.hasEventTypeFilterTarget) {
      this.eventTypeFilterTarget.addEventListener('change', e => {
        this.filterEventsByType(e.target.value);
      });
    }
  }

  handleEventClick(info) {
    if (this.readOnlyValue) return;

    const { event } = info;
    const eventData = {
      id: event.id,
      title: event.title,
      start: event.start,
      end: event.end,
      eventType: event.extendedProps.eventType,
      visibilityLevel: event.extendedProps.visibilityLevel,
      description: event.extendedProps.description,
    };

    this.dispatch('eventClick', { detail: eventData });
  }

  handleEventDidMount(info) {
    const { event } = info;
    const { eventType } = event.extendedProps;

    if (eventType) {
      const color = this.getEventColor(eventType);
      event.setProp('backgroundColor', color);
      event.setProp('borderColor', color);
    }
  }

  handleDateSelect(selectInfo) {
    if (this.readOnlyValue) return;

    const { start } = selectInfo;
    const { end } = selectInfo;

    this.dispatch('dateSelect', {
      detail: { start, end, allDay: selectInfo.allDay },
    });
  }

  handleEventDrop(dropInfo) {
    if (this.readOnlyValue) return;

    const { event } = dropInfo;
    const newStart = event.start;
    const newEnd = event.end || newStart;

    this.updateEvent(event.id, {
      start_time: newStart.toISOString(),
      end_time: newEnd.toISOString(),
    });
  }

  handleEventResize(resizeInfo) {
    if (this.readOnlyValue) return;

    const { event } = resizeInfo;
    const newStart = event.start;
    const newEnd = event.end;

    this.updateEvent(event.id, {
      start_time: newStart.toISOString(),
      end_time: newEnd.toISOString(),
    });
  }

  filterEventsByType(eventType) {
    if (eventType === 'all') {
      this.calendar.getEvents().forEach(event => {
        event.setProp('display', 'auto');
      });
    } else {
      this.calendar.getEvents().forEach(event => {
        const shouldShow = event.extendedProps.eventType === eventType;
        event.setProp('display', shouldShow ? 'auto' : 'none');
      });
    }
  }

  updateEvent(eventId, data) {
    fetch(`/events/${eventId}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
      },
      body: JSON.stringify({ event: data }),
    })
      .then(response => response.json())
      .then(data => {
        if (data.errors) {
          this.calendar.refetchEvents();
        }
      })
      .catch(error => {
        this.calendar.refetchEvents();
      });
  }

  getEventColor(eventType) {
    const colors = {
      personal: '#3b82f6',
      consulta: '#10b981',
      atendimento: '#f59e0b',
      reuniao: '#8b5cf6',
      outro: '#6b7280',
    };
    return colors[eventType] || '#3b82f6';
  }

  refreshEvents() {
    this.calendar.refetchEvents();
  }

  changeView(viewName) {
    this.calendar.changeView(viewName);
  }

  goToDate(date) {
    this.calendar.gotoDate(date);
  }

  today() {
    this.calendar.today();
  }

  prev() {
    this.calendar.prev();
  }

  next() {
    this.calendar.next();
  }
}
