import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["searchInput", "availableList", "selectedList", "checkbox", "hiddenInputs"]

  connect() {
    this.selectedProfessionals = new Set()
    this.updateSelectedList()
    this.loadProfessionals()
  }

  filterProfessionals() {
    const searchTerm = this.searchInputTarget.value.toLowerCase()
    
    if (searchTerm.length >= 2) {
      this.searchProfessionals(searchTerm)
    } else {
      this.loadProfessionals()
    }
  }
  
  async searchProfessionals(searchTerm) {
    try {
      const response = await fetch(`/admin/agendas/search_professionals?search=${encodeURIComponent(searchTerm)}`)
      const data = await response.json()
      
      this.renderProfessionals(data.professionals)
    } catch (error) {
      console.error('Erro ao buscar profissionais:', error)
    }
  }
  
  async loadProfessionals() {
    try {
      const response = await fetch('/admin/agendas/search_professionals')
      const data = await response.json()
      
      this.renderProfessionals(data.professionals)
    } catch (error) {
      console.error('Erro ao carregar profissionais:', error)
    }
  }
  
  renderProfessionals(professionals) {
    let html = ''
    
    professionals.forEach(professional => {
      const specialties = professional.specialties.join(', ')
      
      html += `
        <div class="professional-item p-3 border-b border-gray-100 hover:bg-gray-50 cursor-pointer"
             data-professional-id="${professional.id}"
             data-professional-name="${professional.name}"
             data-professional-specialties="${specialties}"
             data-action="click->agendas-professionals#selectProfessional">
          <div class="flex items-center justify-between">
            <div>
              <div class="text-sm font-medium text-gray-900">${professional.name}</div>
              <div class="text-sm text-gray-500">${specialties}</div>
            </div>
            <div class="flex items-center">
              <input type="checkbox"
                     class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                     data-agendas-professionals-target="checkbox"
                     data-professional-id="${professional.id}">
            </div>
          </div>
        </div>
      `
    })
    
    this.availableListTarget.innerHTML = html
  }

  selectProfessional(event) {
    const item = event.currentTarget
    const professionalId = item.dataset.professionalId
    const checkbox = item.querySelector('input[type="checkbox"]')
    
    if (this.selectedProfessionals.has(professionalId)) {
      this.selectedProfessionals.delete(professionalId)
      checkbox.checked = false
    } else {
      this.selectedProfessionals.add(professionalId)
      checkbox.checked = true
    }
    
    this.updateSelectedList()
    this.updateHiddenInputs()
  }

  selectAllApt() {
    const items = this.availableListTarget.querySelectorAll('.professional-item')
    
    items.forEach(item => {
      const professionalId = item.dataset.professionalId
      const checkbox = item.querySelector('input[type="checkbox"]')
      
      this.selectedProfessionals.add(professionalId)
      checkbox.checked = true
    })
    
    this.updateSelectedList()
    this.updateHiddenInputs()
  }

  removeProfessional(event) {
    const professionalId = event.currentTarget.dataset.professionalId
    this.selectedProfessionals.delete(professionalId)
    
    // Uncheck the checkbox in available list
    const checkbox = this.availableListTarget.querySelector(`input[data-professional-id="${professionalId}"]`)
    if (checkbox) {
      checkbox.checked = false
    }
    
    this.updateSelectedList()
    this.updateHiddenInputs()
  }

  updateSelectedList() {
    if (this.selectedProfessionals.size === 0) {
      this.selectedListTarget.innerHTML = `
        <div class="text-sm text-gray-500 text-center py-8">
          Nenhum profissional selecionado
        </div>
      `
      return
    }

    let html = ''
    this.selectedProfessionals.forEach(professionalId => {
      const item = this.availableListTarget.querySelector(`[data-professional-id="${professionalId}"]`)
      if (item) {
        const name = item.dataset.professionalName
        const specialties = item.dataset.professionalSpecialties
        
        html += `
          <div class="flex items-center justify-between py-2 px-3 bg-blue-50 border border-blue-200 rounded-lg">
            <div>
              <div class="text-sm font-medium text-gray-900">${name}</div>
              <div class="text-sm text-gray-500">${specialties}</div>
            </div>
            <button type="button" 
                    class="text-red-600 hover:text-red-800"
                    data-action="click->agendas-professionals#removeProfessional"
                    data-professional-id="${professionalId}">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
              </svg>
            </button>
          </div>
        `
      }
    })
    
    this.selectedListTarget.innerHTML = html
  }

  updateHiddenInputs() {
    // Clear existing hidden inputs
    this.hiddenInputsTarget.innerHTML = ''
    
    // Add hidden inputs for selected professionals
    this.selectedProfessionals.forEach(professionalId => {
      const input = document.createElement('input')
      input.type = 'hidden'
      input.name = 'agenda[professional_ids][]'
      input.value = professionalId
      this.hiddenInputsTarget.appendChild(input)
    })
  }
}
