import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["calendar", "viewSelector", "eventTypeFilter", "eventModal"]
  static values = {
    eventsUrl: String,
    readOnly: Boolean,
    professionalId: Number
  }

  connect() {
    // Verificar se o FullCalendar global está disponível
    if (window.FullCalendar) {
      this.initializeCalendar()
    } else {
      this.showError('FullCalendar não está disponível')
    }
  }

  disconnect() {
    if (this.calendar) {
      this.calendar.destroy()
    }
  }

  initializeCalendar() {
    const calendarEl = this.calendarTarget
    
    if (!calendarEl) {
      return
    }
    
    try {
      const { Calendar, dayGridPlugin, timeGridPlugin, interactionPlugin, ptBrLocale } = window.FullCalendar
      
      this.calendar = new Calendar(calendarEl, {
        plugins: [dayGridPlugin, timeGridPlugin, interactionPlugin],
        locale: ptBrLocale,
        initialView: 'dayGridMonth',
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
        events: this.eventsUrlValue || '/admin/events/calendar_data',
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
        eventDisplay: 'block',
        eventTimeFormat: {
          hour: '2-digit',
          minute: '2-digit',
          meridiem: false
        }
      })

      this.calendar.render()
      
      // Remover o placeholder de carregamento
      this.removeLoadingPlaceholder()
      
    } catch (error) {
      this.showError('Erro ao inicializar calendário: ' + error.message)
    }
  }

  removeLoadingPlaceholder() {
    const calendarEl = this.calendarTarget
    const placeholder = calendarEl.querySelector('.flex.items-center.justify-center.h-96')
    if (placeholder) {
      placeholder.remove()
    }
  }

  showError(message) {
    const calendarEl = this.calendarTarget
    calendarEl.innerHTML = `
      <div class="flex items-center justify-center h-96 text-red-500">
        <div class="text-center">
          <svg class="mx-auto h-12 w-12 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"/>
          </svg>
          <p class="mt-2 text-lg font-medium">Erro no Calendário</p>
          <p class="mt-1 text-sm">${message}</p>
        </div>
      </div>
    `
  }

  handleEventClick(info) {
    this.showEventModal(info.event)
  }

  handleEventDidMount(info) {
  }

  handleDateSelect(selectInfo) {
    if (this.readOnlyValue) return
  }

  handleEventDrop(dropInfo) {
    if (this.readOnlyValue) return
  }

  handleEventResize(resizeInfo) {
    if (this.readOnlyValue) return
  }

  showEventModal(event) {
    const modal = this.eventModalTarget
    modal.classList.remove('hidden')
  }

  closeEventModal() {
    const modal = this.eventModalTarget
    modal.classList.add('hidden')
  }

  editEvent() {
  }

  prev() {
    if (this.calendar) this.calendar.prev()
  }

  next() {
    if (this.calendar) this.calendar.next()
  }

  today() {
    if (this.calendar) this.calendar.today()
  }

  refreshEvents() {
    if (this.calendar) this.calendar.refetchEvents()
  }
}
