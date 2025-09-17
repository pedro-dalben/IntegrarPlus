import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "agendaSelect", 
    "professionalSelect", 
    "professionalSection",
    "dateSection", 
    "dateSelect",
    "timeSection", 
    "timeSelect",
    "previewSection",
    "submitButton",
    "beneficiaryName",
    "agendaName",
    "professionalName",
    "scheduledDateTime",
    "agendasData"
  ]

  connect() {
    console.log("🔧 AgendaSchedulerController conectado")
    this.agendas = this.parseAgendasData()
  }

  parseAgendasData() {
    try {
      const dataElement = this.agendasDataTarget
      if (dataElement) {
        return JSON.parse(dataElement.textContent)
      }
    } catch (error) {
      console.error("Erro ao parsear dados das agendas:", error)
    }
    return []
  }

  onAgendaChange() {
    const agendaId = this.agendaSelectTarget.value
    
    if (agendaId) {
      const agenda = this.agendas.find(a => a.id == agendaId)
      if (agenda) {
        this.populateProfessionals(agenda.professionals)
        this.showSection(this.professionalSectionTarget)
        this.updatePreview('agenda', agenda.name)
      }
    } else {
      this.hideAllSections()
      this.clearPreview()
    }
  }

  onProfessionalChange() {
    const professionalId = this.professionalSelectTarget.value
    
    if (professionalId) {
      const professional = this.getSelectedProfessional()
      if (professional) {
        this.showSection(this.dateSectionTarget)
        this.updatePreview('professional', professional.name)
      }
    } else {
      this.hideSectionsAfter('professional')
      this.clearPreview()
    }
  }

  onDateChange() {
    const date = this.dateSelectTarget.value
    
    if (date) {
      this.generateTimeSlots(date)
      this.showSection(this.timeSectionTarget)
      this.updatePreview('date', this.formatDate(date))
    } else {
      this.hideSectionsAfter('date')
      this.clearPreview()
    }
  }

  onTimeChange() {
    console.log("🕐 onTimeChange chamado")
    const time = this.timeSelectTarget.value
    console.log("🕐 Horário selecionado:", time)
    if (time) {
      this.updatePreview('time', time)
    } else {
      this.clearPreview()
    }
  }

  populateProfessionals(professionals) {
    const select = this.professionalSelectTarget
    select.innerHTML = '<option value="">Selecione um profissional</option>'
    
    professionals.forEach(professional => {
      const option = document.createElement('option')
      option.value = professional.id
      option.textContent = professional.name
      select.appendChild(option)
    })
  }

  generateTimeSlots(date) {
    const agenda = this.getSelectedAgenda()
    if (!agenda) return

    const select = this.timeSelectTarget
    select.innerHTML = '<option value="">Selecione um horário</option>'

    // Simular horários disponíveis baseados na agenda
    // Em uma implementação real, isso viria de uma API
    const slots = this.calculateAvailableSlots(date, agenda)
    
    slots.forEach(slot => {
      const option = document.createElement('option')
      option.value = slot.time
      option.textContent = slot.display
      select.appendChild(option)
    })
  }

  calculateAvailableSlots(date, agenda) {
    const slots = []
    const slotDuration = agenda.slot_duration_minutes || 50
    const buffer = agenda.buffer_minutes || 10
    const totalMinutes = slotDuration + buffer

    // Verificar se a agenda tem working_hours configurados
    if (!agenda.working_hours || !agenda.working_hours.weekdays) {
      console.warn('Agenda sem working_hours configurados, usando horários padrão')
      return this.getDefaultSlots(slotDuration, buffer)
    }

    const selectedDate = new Date(date)
    const weekday = selectedDate.getDay() // 0 = domingo, 1 = segunda, etc.
    
    // Encontrar configuração para o dia da semana
    const dayConfig = agenda.working_hours.weekdays.find(d => d.wday === weekday)
    
    if (!dayConfig || !dayConfig.periods || dayConfig.periods.length === 0) {
      console.log(`Nenhum período configurado para ${this.getDayName(weekday)}`)
      return []
    }

    // Gerar slots para cada período configurado
    dayConfig.periods.forEach(period => {
      const periodSlots = this.generateSlotsForPeriod(period, slotDuration, buffer, totalMinutes)
      slots.push(...periodSlots)
    })

    return slots.sort((a, b) => a.time.localeCompare(b.time))
  }

  getDefaultSlots(slotDuration, buffer) {
    // Fallback para horários padrão se não houver working_hours
    const slots = []
    const startHour = 8
    const endHour = 17
    const totalMinutes = slotDuration + buffer

    for (let hour = startHour; hour < endHour; hour++) {
      for (let minutes = 0; minutes < 60; minutes += totalMinutes) {
        if (hour === endHour - 1 && minutes + slotDuration > 60) break
        
        const timeString = `${hour.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}`
        const endTime = this.addMinutes(timeString, slotDuration)
        
        slots.push({
          time: timeString,
          display: `${timeString} - ${endTime}`
        })
      }
    }

    return slots
  }

  generateSlotsForPeriod(period, slotDuration, buffer, totalMinutes) {
    const slots = []
    const startTime = this.parseTime(period.start)
    const endTime = this.parseTime(period.end)
    
    if (!startTime || !endTime) {
      console.warn('Período inválido:', period)
      return []
    }

    let currentTime = startTime
    
    while (currentTime < endTime) {
      const nextTime = this.addMinutesToTime(currentTime, totalMinutes)
      
      // Verificar se o slot cabe no período
      if (nextTime <= endTime) {
        const timeString = this.formatTime(currentTime)
        const endTimeString = this.formatTime(this.addMinutesToTime(currentTime, slotDuration))
        
        slots.push({
          time: timeString,
          display: `${timeString} - ${endTimeString}`
        })
      }
      
      currentTime = nextTime
    }

    return slots
  }

  parseTime(timeString) {
    const [hours, minutes] = timeString.split(':').map(Number)
    return { hours, minutes }
  }

  formatTime(time) {
    return `${time.hours.toString().padStart(2, '0')}:${time.minutes.toString().padStart(2, '0')}`
  }

  addMinutesToTime(time, minutes) {
    const totalMinutes = time.hours * 60 + time.minutes + minutes
    return {
      hours: Math.floor(totalMinutes / 60),
      minutes: totalMinutes % 60
    }
  }

  getDayName(weekday) {
    const days = ['Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado']
    return days[weekday]
  }

  addMinutes(timeString, minutes) {
    const [hours, mins] = timeString.split(':').map(Number)
    const totalMinutes = hours * 60 + mins + minutes
    const newHours = Math.floor(totalMinutes / 60)
    const newMins = totalMinutes % 60
    return `${newHours.toString().padStart(2, '0')}:${newMins.toString().padStart(2, '0')}`
  }

  getSelectedAgenda() {
    const agendaId = this.agendaSelectTarget.value
    return this.agendas.find(a => a.id == agendaId)
  }

  getSelectedProfessional() {
    const professionalId = this.professionalSelectTarget.value
    const agenda = this.getSelectedAgenda()
    if (agenda) {
      return agenda.professionals.find(p => p.id == professionalId)
    }
    return null
  }

  showSection(section) {
    section.classList.remove('hidden')
  }

  hideSection(section) {
    section.classList.add('hidden')
  }

  hideAllSections() {
    this.hideSection(this.professionalSectionTarget)
    this.hideSection(this.dateSectionTarget)
    this.hideSection(this.timeSectionTarget)
    this.hideSection(this.previewSectionTarget)
    this.disableSubmit()
  }

  hideSectionsAfter(sectionName) {
    switch (sectionName) {
      case 'agenda':
        this.hideSection(this.professionalSectionTarget)
        this.hideSection(this.dateSectionTarget)
        this.hideSection(this.timeSectionTarget)
        this.hideSection(this.previewSectionTarget)
        break
      case 'professional':
        this.hideSection(this.dateSectionTarget)
        this.hideSection(this.timeSectionTarget)
        this.hideSection(this.previewSectionTarget)
        break
      case 'date':
        this.hideSection(this.timeSectionTarget)
        this.hideSection(this.previewSectionTarget)
        break
    }
    this.disableSubmit()
  }

  updatePreview(field, value) {
    console.log("📝 updatePreview chamado:", field, value)
    switch (field) {
      case 'agenda':
        this.agendaNameTarget.textContent = value
        break
      case 'professional':
        this.professionalNameTarget.textContent = value
        break
      case 'date':
        this.scheduledDateTimeTarget.textContent = value
        break
      case 'time':
        console.log("🕐 Atualizando preview com horário:", value)
        break
    }

    // Verificar se todos os campos estão preenchidos
    const allFieldsFilled = this.agendaSelectTarget.value && 
        this.professionalSelectTarget.value && 
        this.dateSelectTarget.value && 
        this.timeSelectTarget.value
    
    console.log("✅ Campos preenchidos:", {
      agenda: this.agendaSelectTarget.value,
      professional: this.professionalSelectTarget.value,
      date: this.dateSelectTarget.value,
      time: this.timeSelectTarget.value,
      allFilled: allFieldsFilled
    })
    
    if (allFieldsFilled) {
      console.log("🎉 Habilitando botão de submit")
      this.showSection(this.previewSectionTarget)
      this.enableSubmit()
      this.updateFinalPreview()
    }
  }

  updateFinalPreview() {
    const date = this.dateSelectTarget.value
    const time = this.timeSelectTarget.value
    const formattedDate = this.formatDate(date)
    this.scheduledDateTimeTarget.textContent = `${formattedDate} às ${time}`
  }

  formatDate(dateString) {
    const date = new Date(dateString)
    return date.toLocaleDateString('pt-BR')
  }

  clearPreview() {
    this.agendaNameTarget.textContent = '-'
    this.professionalNameTarget.textContent = '-'
    this.scheduledDateTimeTarget.textContent = '-'
    this.hideSection(this.previewSectionTarget)
    this.disableSubmit()
  }

  enableSubmit() {
    this.submitButtonTarget.disabled = false
  }

  disableSubmit() {
    this.submitButtonTarget.disabled = true
  }
}
