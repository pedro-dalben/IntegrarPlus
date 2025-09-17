import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["periodLabel"]
  static values = { 
    currentDate: String,
    viewType: String,
    professionalId: String,
    agendaId: String
  }
  
  connect() {
    this.currentDate = new Date(this.currentDateValue)
    this.viewType = this.viewTypeValue
    this.updatePeriodLabel()
  }
  
  previousPeriod() {
    this.changeDate(-1)
  }
  
  nextPeriod() {
    this.changeDate(1)
  }
  
  goToToday() {
    this.currentDate = new Date()
    this.updateCalendar()
  }
  
  changeView(event) {
    this.viewType = event.target.dataset.view
    this.updateCalendar()
  }
  
  changeDate(direction) {
    switch (this.viewType) {
      case 'month':
        this.currentDate.setMonth(this.currentDate.getMonth() + direction)
        break
      case 'week':
        this.currentDate.setDate(this.currentDate.getDate() + (direction * 7))
        break
      case 'day':
        this.currentDate.setDate(this.currentDate.getDate() + direction)
        break
    }
    
    this.updateCalendar()
  }
  
  updateCalendar() {
    const params = new URLSearchParams({
      date: this.currentDate.toISOString().split('T')[0],
      view: this.viewType
    })
    
    if (this.professionalIdValue) {
      params.append('professional_id', this.professionalIdValue)
    }
    
    if (this.agendaIdValue) {
      params.append('agenda_id', this.agendaIdValue)
    }
    
    fetch(`/admin/calendar?${params.toString()}`, {
      method: 'GET',
      headers: {
        'Accept': 'text/html',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => response.text())
    .then(html => {
      this.element.innerHTML = html
    })
    .catch(error => {
      console.error('Erro ao atualizar calendário:', error)
    })
  }
  
  updatePeriodLabel() {
    if (this.hasPeriodLabelTarget) {
      this.periodLabelTarget.textContent = this.getPeriodLabel()
    }
  }
  
  getPeriodLabel() {
    const options = { 
      year: 'numeric', 
      month: 'long' 
    }
    
    switch (this.viewType) {
      case 'month':
        return this.currentDate.toLocaleDateString('pt-BR', options)
      case 'week':
        const startOfWeek = this.getStartOfWeek()
        const endOfWeek = this.getEndOfWeek()
        return `${startOfWeek.toLocaleDateString('pt-BR')} - ${endOfWeek.toLocaleDateString('pt-BR')}`
      case 'day':
        return this.currentDate.toLocaleDateString('pt-BR')
      default:
        return this.currentDate.toLocaleDateString('pt-BR', options)
    }
  }
  
  getStartOfWeek() {
    const date = new Date(this.currentDate)
    const day = date.getDay()
    const diff = date.getDate() - day + (day === 0 ? -6 : 1)
    return new Date(date.setDate(diff))
  }
  
  getEndOfWeek() {
    const startOfWeek = this.getStartOfWeek()
    return new Date(startOfWeek.getTime() + 6 * 24 * 60 * 60 * 1000)
  }
  
  // Métodos para interação com eventos
  selectEvent(event) {
    const eventId = event.currentTarget.dataset.eventId
    this.showEventDetails(eventId)
  }
  
  showEventDetails(eventId) {
    // Implementar modal ou sidebar com detalhes do evento
    console.log('Mostrar detalhes do evento:', eventId)
  }
  
  createEvent(date, time) {
    // Implementar criação de novo evento
    console.log('Criar evento para:', date, time)
  }
  
  editEvent(eventId) {
    // Implementar edição de evento
    console.log('Editar evento:', eventId)
  }
  
  deleteEvent(eventId) {
    if (confirm('Tem certeza que deseja excluir este evento?')) {
      // Implementar exclusão de evento
      console.log('Excluir evento:', eventId)
    }
  }
}
