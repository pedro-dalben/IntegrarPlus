import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["startDateContainer", "endDateContainer"]

  toggleDateInputs(event) {
    const period = event.target.value
    
    if (period) {
      // Se um período específico foi selecionado, ocultar os campos de data
      this.startDateContainerTarget.classList.add("hidden")
      this.endDateContainerTarget.classList.add("hidden")
      
      // Limpar os valores dos campos de data
      if (this.startDateContainerTarget.querySelector("input")) {
        this.startDateContainerTarget.querySelector("input").value = ""
      }
      if (this.endDateContainerTarget.querySelector("input")) {
        this.endDateContainerTarget.querySelector("input").value = ""
      }
    } else {
      // Se "Todos os períodos" foi selecionado, mostrar os campos de data
      this.startDateContainerTarget.classList.remove("hidden")
      this.endDateContainerTarget.classList.remove("hidden")
    }
  }

  applyPeriodFilter(event) {
    const period = event.target.value
    const today = new Date()
    
    if (period) {
      const startDateInput = this.startDateContainerTarget.querySelector("input")
      const endDateInput = this.endDateContainerTarget.querySelector("input")
      
      let startDate, endDate
      
      switch (period) {
        case "today":
          startDate = endDate = today.toISOString().split('T')[0]
          break
        case "this_week":
          const startOfWeek = new Date(today.setDate(today.getDate() - today.getDay()))
          startDate = startOfWeek.toISOString().split('T')[0]
          endDate = new Date().toISOString().split('T')[0]
          break
        case "this_month":
          startDate = new Date(today.getFullYear(), today.getMonth(), 1).toISOString().split('T')[0]
          endDate = new Date().toISOString().split('T')[0]
          break
        case "last_7_days":
          const weekAgo = new Date(today.setDate(today.getDate() - 7))
          startDate = weekAgo.toISOString().split('T')[0]
          endDate = new Date().toISOString().split('T')[0]
          break
        case "last_30_days":
          const monthAgo = new Date(today.setDate(today.getDate() - 30))
          startDate = monthAgo.toISOString().split('T')[0]
          endDate = new Date().toISOString().split('T')[0]
          break
      }
      
      if (startDate && endDate && startDateInput && endDateInput) {
        startDateInput.value = startDate
        endDateInput.value = endDate
      }
    }
  }
}
