import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "hidden"]
  static values = { 
    format: { type: String, default: "HH:mm" }
  }

  connect() {
    this.initializeTimeInput()
  }

  initializeTimeInput() {
    const input = this.inputTarget
    const hidden = this.hiddenTarget

    // Converter valor inicial se existir
    if (hidden.value && hidden.value !== '0') {
      const minutes = parseInt(hidden.value)
      input.value = this.minutesToHHMM(minutes)
    }

    // Adicionar máscara de tempo
    input.addEventListener('input', (e) => {
      this.formatTimeInput(e.target)
    })

    // Converter antes do submit
    input.addEventListener('blur', () => {
      this.convertToMinutes()
    })

    // Validar formato
    input.addEventListener('keyup', (e) => {
      this.validateTimeFormat(e.target)
    })
  }

  formatTimeInput(input) {
    let value = input.value.replace(/\D/g, '')
    
    if (value.length > 4) {
      value = value.substring(0, 4)
    }

    if (value.length >= 2) {
      const hours = value.substring(0, 2)
      const minutes = value.substring(2, 4)
      
      if (parseInt(hours) > 99) {
        value = '99' + value.substring(2)
      }
      
      if (parseInt(minutes) > 59) {
        value = hours + '59'
      }
      
      input.value = hours + ':' + minutes
    } else {
      input.value = value
    }
  }

  validateTimeFormat(input) {
    const value = input.value
    const timeRegex = /^([0-9]{1,2}):([0-5][0-9])$/
    
    if (value && !timeRegex.test(value)) {
      input.classList.add('border-red-500')
    } else {
      input.classList.remove('border-red-500')
    }
  }

  convertToMinutes() {
    const input = this.inputTarget
    const hidden = this.hiddenTarget
    const value = input.value.trim()

    if (!value) {
      hidden.value = '0'
      return
    }

    const timeRegex = /^([0-9]{1,2}):([0-5][0-9])$/
    const match = value.match(timeRegex)

    if (match) {
      const hours = parseInt(match[1])
      const minutes = parseInt(match[2])
      const totalMinutes = (hours * 60) + minutes
      
      hidden.value = totalMinutes.toString()
      input.value = this.minutesToHHMM(totalMinutes)
    } else {
      // Tentar converter número simples para HH:MM
      const numValue = parseInt(value.replace(/\D/g, ''))
      if (!isNaN(numValue)) {
        const totalMinutes = Math.min(numValue, 99 * 60 + 59) // Máximo 99:59
        hidden.value = totalMinutes.toString()
        input.value = this.minutesToHHMM(totalMinutes)
      } else {
        hidden.value = '0'
        input.value = ''
      }
    }
  }

  minutesToHHMM(minutes) {
    const hours = Math.floor(minutes / 60)
    const mins = minutes % 60
    return sprintf('%02d:%02d', hours, mins)
  }

  // Função sprintf simples
  sprintf(format, ...args) {
    return format.replace(/%(\d*)d/g, (match, width) => {
      const num = args.shift()
      return width ? num.toString().padStart(parseInt(width), '0') : num.toString()
    })
  }
}
