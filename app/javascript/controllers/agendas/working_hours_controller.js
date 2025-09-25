import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["preview", "duration", "buffer", "periods", "exceptions", "workingHoursInput"]

  connect() {
    this.workingHours = {
      slot_duration: 50,
      buffer: 10,
      weekdays: [],
      exceptions: []
    }
    this.updatePreview()
  }

  updatePreview() {
    const duration = this.element.querySelector('input[name*="slot_duration_minutes"]')?.value || 50
    const buffer = this.element.querySelector('input[name*="buffer_minutes"]')?.value || 10
    
    if (this.hasDurationTarget) {
      this.durationTarget.textContent = duration
    }
    if (this.hasBufferTarget) {
      this.bufferTarget.textContent = buffer
    }
    
    this.workingHours.slot_duration = parseInt(duration)
    this.workingHours.buffer = parseInt(buffer)
    this.updateWorkingHoursInput()
  }

  toggleDay(event) {
    const checkbox = event.target
    const day = parseInt(checkbox.dataset.day)
    const periodsContainer = this.element.querySelector(`[data-day="${day}"] [data-agendas-working-hours-target="periods"]`)
    
    if (checkbox.checked) {
      this.addPeriod(day)
    } else {
      periodsContainer.innerHTML = ''
      this.removeDayFromWorkingHours(day)
    }
  }

  addPeriod(day) {
    const periodsContainer = this.element.querySelector(`[data-day="${day}"] [data-agendas-working-hours-target="periods"]`)
    
    const periodHtml = `
      <div class="flex items-center gap-2 p-2 bg-gray-50 rounded-lg">
        <input type="time" 
               class="px-2 py-1 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
               data-period-start
               value="08:00">
        <span class="text-sm text-gray-500">até</span>
        <input type="time" 
               class="px-2 py-1 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
               data-period-end
               value="12:00">
        <button type="button" 
                class="text-red-600 hover:text-red-800"
                data-action="click->agendas-working-hours#removePeriod">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
          </svg>
        </button>
      </div>
    `
    
    periodsContainer.insertAdjacentHTML('beforeend', periodHtml)
    this.updateWorkingHoursInput()
  }

  removePeriod(event) {
    event.target.closest('.flex').remove()
    this.updateWorkingHoursInput()
  }

  copyToAllDays() {
    const sourceDay = this.element.querySelector('input[type="checkbox"]:checked')
    if (!sourceDay) {
      alert('Selecione pelo menos um dia para copiar')
      return
    }
    
    const sourceDayValue = parseInt(sourceDay.dataset.day)
    const sourcePeriods = this.element.querySelector(`[data-day="${sourceDayValue}"] [data-agendas-working-hours-target="periods"]`)
    
    if (sourcePeriods.children.length === 0) {
      alert('O dia selecionado não possui períodos para copiar')
      return
    }
    
    // Copy to all other checked days
    const allCheckboxes = this.element.querySelectorAll('input[type="checkbox"]')
    allCheckboxes.forEach(checkbox => {
      if (checkbox.checked && parseInt(checkbox.dataset.day) !== sourceDayValue) {
        const day = parseInt(checkbox.dataset.day)
        const periodsContainer = this.element.querySelector(`[data-day="${day}"] [data-agendas-working-hours-target="periods"]`)
        periodsContainer.innerHTML = sourcePeriods.innerHTML
      }
    })
    
    this.updateWorkingHoursInput()
  }

  async generatePreview() {
    try {
      // Mostrar loading
      this.showLoading()
      
      // Mostrar container do preview
      const previewContainer = document.getElementById('preview-container')
      if (previewContainer) {
        previewContainer.classList.remove('hidden')
      }
      
      // Fazer chamada AJAX para gerar preview
      const params = new URLSearchParams({
        working_hours: JSON.stringify(this.workingHours)
      })
      
      const response = await fetch(`/admin/agendas/preview_slots?${params}`, {
        method: 'GET',
        headers: {
          'Accept': 'text/vnd.turbo-stream.html',
          'X-Requested-With': 'XMLHttpRequest'
        }
      })

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      // Processar resposta Turbo Stream
      const turboStream = await response.text()
      Turbo.renderStreamMessage(turboStream)
      
    } catch (error) {
      alert('Erro ao gerar preview. Tente novamente.')
    } finally {
      this.hideLoading()
    }
  }

  showLoading() {
    // Adicionar indicador de loading se necessário
    const button = this.element.querySelector('[data-action="click->agendas-working-hours#generatePreview"]')
    if (button) {
      button.disabled = true
      button.textContent = 'Gerando...'
    }
  }

  hideLoading() {
    // Remover indicador de loading
    const button = this.element.querySelector('[data-action="click->agendas-working-hours#generatePreview"]')
    if (button) {
      button.disabled = false
      button.textContent = 'Gerar Prévia de Slots'
    }
  }

  addException() {
    const exceptionsContainer = this.exceptionsTarget
    
    const exceptionHtml = `
      <div class="flex items-center gap-2 p-2 bg-gray-50 rounded-lg">
        <input type="date" 
               class="px-2 py-1 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
               data-exception-date>
        <select class="px-2 py-1 text-sm border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                data-exception-type>
          <option value="closed">Fechado</option>
          <option value="special">Horário Especial</option>
        </select>
        <button type="button" 
                class="text-red-600 hover:text-red-800"
                data-action="click->agendas-working-hours#removeException">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
          </svg>
        </button>
      </div>
    `
    
    exceptionsContainer.insertAdjacentHTML('beforeend', exceptionHtml)
    this.updateWorkingHoursInput()
  }

  removeException(event) {
    event.target.closest('.flex').remove()
    this.updateWorkingHoursInput()
  }

  updateWorkingHoursInput() {
    const weekdays = []
    
    // Collect weekday data
    for (let wday = 0; wday < 7; wday++) {
      const checkbox = this.element.querySelector(`input[data-day="${wday}"]`)
      if (checkbox && checkbox.checked) {
        const periodsContainer = this.element.querySelector(`[data-day="${wday}"] [data-agendas-working-hours-target="periods"]`)
        const periods = []
        
        periodsContainer.querySelectorAll('.flex').forEach(periodDiv => {
          const start = periodDiv.querySelector('[data-period-start]').value
          const end = periodDiv.querySelector('[data-period-end]').value
          
          if (start && end) {
            periods.push({ start, end })
          }
        })
        
        if (periods.length > 0) {
          weekdays.push({ wday, periods })
        }
      }
    }
    
    // Collect exceptions
    const exceptions = []
    this.exceptionsTarget.querySelectorAll('.flex').forEach(exceptionDiv => {
      const date = exceptionDiv.querySelector('[data-exception-date]').value
      const type = exceptionDiv.querySelector('[data-exception-type]').value
      
      if (date) {
        if (type === 'closed') {
          exceptions.push({ date, closed: true })
        } else {
          // For special hours, you'd need additional inputs
          exceptions.push({ date, periods: [] })
        }
      }
    })
    
    this.workingHours.weekdays = weekdays
    this.workingHours.exceptions = exceptions
    
    if (this.hasWorkingHoursInputTarget) {
      this.workingHoursInputTarget.value = JSON.stringify(this.workingHours)
    }
  }

  removeDayFromWorkingHours(day) {
    this.workingHours.weekdays = this.workingHours.weekdays.filter(d => d.wday !== day)
    this.updateWorkingHoursInput()
  }
}
