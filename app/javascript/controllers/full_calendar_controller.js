import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['calendar', 'viewSelector', 'eventTypeFilter', 'eventModal'];
  static values = {
    eventsData: Array,
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

  async initializeCalendar() {
    const calendarEl = this.calendarTarget;
    let eventsData = this.eventsDataValue || [];

    // Se eventsData é uma string JSON, parse ela
    if (typeof eventsData === 'string') {
      try {
        eventsData = JSON.parse(eventsData);
      } catch (e) {
        eventsData = [];
      }
    }

    try {
      // Carregar FullCalendar dinamicamente
      const { Calendar } = await import('@fullcalendar/core');
      const dayGridPlugin = await import('@fullcalendar/daygrid');
      const timeGridPlugin = await import('@fullcalendar/timegrid');
      const interactionPlugin = await import('@fullcalendar/interaction');
      const listPlugin = await import('@fullcalendar/list');

      this.calendar = new Calendar(calendarEl, {
        plugins: [
          dayGridPlugin.default,
          timeGridPlugin.default,
          interactionPlugin.default,
          listPlugin.default,
        ],
        initialView: 'dayGridMonth',
        headerToolbar: {
          left: 'prev,next today',
          center: 'title',
          right: 'dayGridMonth,timeGridWeek,timeGridDay',
        },
        buttonText: {
          today: 'Hoje',
          month: 'Mês',
          week: 'Semana',
          day: 'Dia',
        },
        height: 'auto',
        events: eventsData,
        eventClick: this.handleEventClick.bind(this),
        selectable: !this.readOnlyValue,
        select: this.handleDateSelect.bind(this),
        editable: !this.readOnlyValue,
        slotMinTime: '07:00:00',
        slotMaxTime: '20:00:00',
        allDaySlot: false,
        firstDay: 1,
        nowIndicator: true,
      });

      this.calendar.render();
    } catch (error) {
      // Mostrar mensagem de erro no elemento
      calendarEl.innerHTML = `
        <div class="flex items-center justify-center h-96 text-red-500">
          <div class="text-center">
            <svg class="mx-auto h-12 w-12 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.732-.833-2.5 0L4.268 19.5c-.77.833.192 2.5 1.732 2.5z"/>
            </svg>
            <p class="mt-2">Erro ao carregar calendário</p>
            <p class="text-sm text-gray-500">Verifique o console para mais detalhes</p>
            <p class="text-xs text-gray-400 mt-2">Erro: ${error.message}</p>
          </div>
        </div>
      `;
    }
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
    const { event } = info;
    const { extendedProps } = event;

    const eventDetails = `
      <div class="space-y-2">
        <div class="flex items-center gap-2">
          <div class="w-3 h-3 rounded-full" style="background-color: ${event.color}"></div>
          <span class="font-medium text-gray-900 dark:text-white">${event.title}</span>
        </div>
        <div class="text-sm text-gray-600 dark:text-gray-400">
          <p><strong>Data:</strong> ${this.formatDate(event.start)}</p>
          <p><strong>Horário:</strong> ${this.formatTime(event.start)} - ${this.formatTime(event.end)}</p>
          <p><strong>Tipo:</strong> ${extendedProps.event_type}</p>
          <p><strong>Profissional:</strong> ${extendedProps.professional_name}</p>
          ${extendedProps.description ? `<p><strong>Descrição:</strong> ${extendedProps.description}</p>` : ''}
        </div>
      </div>
    `;

    document.getElementById('calendar-event-details').innerHTML = eventDetails;
    document.getElementById('calendar-event-title').textContent = event.title;
    this.showEventModal();
  }

  handleEventDidMount(info) {
    const { event } = info;
    const { extendedProps } = event;

    // Adicionar tooltip
    info.el.setAttribute('title', `${event.title} - ${extendedProps.professional_name}`);

    // Adicionar classes CSS personalizadas
    info.el.classList.add('event-item');

    // Adicionar indicador de tipo
    const typeIndicator = document.createElement('div');
    typeIndicator.className = 'event-type-indicator';
    typeIndicator.style.backgroundColor = event.color;
    typeIndicator.style.width = '4px';
    typeIndicator.style.height = '100%';
    typeIndicator.style.position = 'absolute';
    typeIndicator.style.left = '0';
    typeIndicator.style.top = '0';
    info.el.appendChild(typeIndicator);
  }

  handleDateSelect(selectInfo) {
    if (this.readOnlyValue) return;

    const startDate = selectInfo.start;
    const endDate = selectInfo.end;
    const { allDay } = selectInfo;

    // Aqui você pode implementar a lógica para criar um novo evento

    // Exemplo: abrir modal para criar evento
    this.createNewEvent(startDate, endDate, allDay);
  }

  handleEventDrop(info) {
    if (this.readOnlyValue) return;

    const { event } = info;
    const newStart = event.start;
    const newEnd = event.end;

    // Aqui você pode implementar a lógica para atualizar o evento

    // Exemplo: enviar requisição para atualizar
    this.updateEvent(event.id, { start: newStart, end: newEnd });
  }

  handleEventResize(info) {
    if (this.readOnlyValue) return;

    const { event } = info;
    const newStart = event.start;
    const newEnd = event.end;

    // Aqui você pode implementar a lógica para redimensionar o evento

    // Exemplo: enviar requisição para atualizar
    this.updateEvent(event.id, { start: newStart, end: newEnd });
  }

  filterEventsByType(eventType) {
    if (eventType === 'all') {
      this.calendar.removeAllEventSources();
      this.calendar.addEventSource(this.eventsDataValue);
    } else {
      const filteredEvents = this.eventsDataValue.filter(
        event => event.extendedProps.event_type === eventType
      );
      this.calendar.removeAllEventSources();
      this.calendar.addEventSource(filteredEvents);
    }
  }

  prev() {
    this.calendar.prev();
  }

  next() {
    this.calendar.next();
  }

  today() {
    this.calendar.today();
  }

  refreshEvents() {
    this.calendar.refetchEvents();
  }

  showEventModal() {
    if (this.hasEventModalTarget) {
      this.eventModalTarget.classList.remove('hidden');
    }
  }

  closeEventModal() {
    if (this.hasEventModalTarget) {
      this.eventModalTarget.classList.add('hidden');
    }
  }

  editEvent() {
    // Implementar lógica de edição
    this.closeEventModal();
  }

  createNewEvent(startDate, endDate, allDay) {
    // Implementar lógica para criar novo evento
  }

  updateEvent(eventId, eventData) {
    // Implementar lógica para atualizar evento
  }

  formatDate(date) {
    return date.toLocaleDateString('pt-BR', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    });
  }

  formatTime(date) {
    return date.toLocaleTimeString('pt-BR', {
      hour: '2-digit',
      minute: '2-digit',
    });
  }
}
