import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "form", "title", "submitButton", "startTime", "endTime"]
  static values = { 
    professionalId: Number,
    readOnly: Boolean
  }

  connect() {
    this.bindEvents()
  }

  bindEvents() {
    document.addEventListener('dateSelect', this.handleDateSelect.bind(this))
    document.addEventListener('eventClick', this.handleEventClick.bind(this))
  }

  open(event) {
    const target = event.currentTarget.dataset.eventModalTarget
    
    if (target === 'new') {
      this.openNewEventModal()
    } else if (target === 'edit') {
      this.openEditEventModal(event.detail)
    }
    
    this.showModal()
  }

  close() {
    this.hideModal()
    this.resetForm()
  }

  openNewEventModal() {
    this.titleTarget.textContent = 'Novo Evento'
    this.submitButtonTarget.textContent = 'Criar Evento'
    this.submitButtonTarget.dataset.action = 'click->event-modal#createEvent'
    
    this.resetForm()
    this.setDefaultTimes()
  }

  openEditEventModal(eventData) {
    this.titleTarget.textContent = 'Editar Evento'
    this.submitButtonTarget.textContent = 'Atualizar Evento'
    this.submitButtonTarget.dataset.action = 'click->event-modal#updateEvent'
    
    this.populateForm(eventData)
  }

  populateForm(eventData) {
    const form = this.formTarget
    form.querySelector('[name="event[title]"]').value = eventData.title || ''
    form.querySelector('[name="event[description]"]').value = eventData.description || ''
    form.querySelector('[name="event[start_time]"]').value = this.formatDateTimeForInput(eventData.start)
    form.querySelector('[name="event[end_time]"]').value = this.formatDateTimeForInput(eventData.end)
    form.querySelector('[name="event[event_type]"]').value = eventData.event_type || ''
    form.querySelector('[name="event[visibility_level]"]').value = eventData.visibility_level || ''
    
    form.dataset.eventId = eventData.id
  }

  resetForm() {
    const form = this.formTarget
    form.reset()
    delete form.dataset.eventId
    
    this.setDefaultTimes()
  }

  setDefaultTimes() {
    const now = new Date()
    const startTime = new Date(now.getTime() + 60 * 60 * 1000)
    const endTime = new Date(startTime.getTime() + 60 * 60 * 1000)
    
    this.startTimeTarget.value = this.formatDateTimeForInput(startTime)
    this.endTimeTarget.value = this.formatDateTimeForInput(endTime)
  }

  formatDateTimeForInput(date) {
    const d = new Date(date)
    const year = d.getFullYear()
    const month = String(d.getMonth() + 1).padStart(2, '0')
    const day = String(d.getDate()).padStart(2, '0')
    const hours = String(d.getHours()).padStart(2, '0')
    const minutes = String(d.getMinutes()).padStart(2, '0')
    
    return `${year}-${month}-${day}T${hours}:${minutes}`
  }

  handleDateSelect(event) {
    const { start, end } = event.detail
    
    if (this.startTimeTarget && this.endTimeTarget) {
      this.startTimeTarget.value = this.formatDateTimeForInput(start)
      this.endTimeTarget.value = this.formatDateTimeForInput(end)
    }
  }

  handleEventClick(event) {
    this.openEditEventModal(event.detail)
  }

  async createEvent() {
    if (!this.validateForm()) return
    
    const formData = new FormData(this.formTarget)
    formData.append('event[professional_id]', this.professionalIdValue)
    
    try {
      const response = await fetch('/events', {
        method: 'POST',
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: formData
      })

      if (response.ok) {
        this.close()
        this.dispatch('eventCreated')
        this.refreshCalendar()
      } else {
        const errorData = await response.json()
        this.showErrors(errorData.errors)
      }
    } catch (error) {
      this.showError('Erro ao criar evento. Tente novamente.')
    }
  }

  async updateEvent() {
    if (!this.validateForm()) return
    
    const eventId = this.formTarget.dataset.eventId
    if (!eventId) return
    
    const formData = new FormData(this.formTarget)
    
    try {
      const response = await fetch(`/events/${eventId}`, {
        method: 'PATCH',
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: formData
      })

      if (response.ok) {
        this.close()
        this.dispatch('eventUpdated')
        this.refreshCalendar()
      } else {
        const errorData = await response.json()
        this.showErrors(errorData.errors)
      }
    } catch (error) {
      this.showError('Erro ao atualizar evento. Tente novamente.')
    }
  }

  validateForm() {
    const form = this.formTarget
    const requiredFields = form.querySelectorAll('[required]')
    let isValid = true
    
    requiredFields.forEach(field => {
      if (!field.value.trim()) {
        this.showFieldError(field, 'Este campo é obrigatório')
        isValid = false
      } else {
        this.clearFieldError(field)
      }
    })
    
    const startTime = new Date(this.startTimeTarget.value)
    const endTime = new Date(this.endTimeTarget.value)
    
    if (endTime <= startTime) {
      this.showFieldError(this.endTimeTarget, 'A data de fim deve ser posterior à data de início')
      isValid = false
    } else {
      this.clearFieldError(this.endTimeTarget)
    }
    
    return isValid
  }

  showFieldError(field, message) {
    this.clearFieldError(field)
    
    const errorDiv = document.createElement('div')
    errorDiv.className = 'mt-1 text-sm text-red-600 dark:text-red-400'
    errorDiv.textContent = message
    
    field.parentNode.appendChild(errorDiv)
    field.classList.add('border-red-500', 'focus:border-red-500', 'focus:ring-red-500')
  }

  clearFieldError(field) {
    const errorDiv = field.parentNode.querySelector('.text-red-600')
    if (errorDiv) {
      errorDiv.remove()
    }
    
    field.classList.remove('border-red-500', 'focus:border-red-500', 'focus:ring-red-500')
  }

  showErrors(errors) {
    if (Array.isArray(errors)) {
      errors.forEach(error => this.showError(error))
    } else {
      this.showError('Erro ao processar formulário')
    }
  }

  showError(message) {
    const errorDiv = document.createElement('div')
    errorDiv.className = 'mb-4 rounded-md bg-red-50 p-4 dark:bg-red-900/20'
    errorDiv.innerHTML = `
      <div class="flex">
        <div class="flex-shrink-0">
          <svg class="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
          </svg>
        </div>
        <div class="ml-3">
          <p class="text-sm font-medium text-red-800 dark:text-red-200">${message}</p>
        </div>
      </div>
    `
    
    const form = this.formTarget
    form.insertBefore(errorDiv, form.firstChild)
    
    setTimeout(() => {
      if (errorDiv.parentNode) {
        errorDiv.remove()
      }
    }, 5000)
  }

  showModal() {
    this.modalTarget.classList.remove('hidden')
    document.body.classList.add('overflow-hidden')
  }

  hideModal() {
    this.modalTarget.classList.add('hidden')
    document.body.classList.remove('overflow-hidden')
  }

  refreshCalendar() {
    const calendarController = this.application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller*="calendar"]'),
      'calendar'
    )
    
    if (calendarController) {
      calendarController.refreshEvents()
    }
  }
}
