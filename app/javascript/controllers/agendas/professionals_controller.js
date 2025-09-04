import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["searchInput", "availableList", "selectedList", "checkbox", "hiddenInputs"]

  connect() {
    this.selectedProfessionals = new Set()
    this.updateSelectedList()
  }

  filterProfessionals() {
    const searchTerm = this.searchInputTarget.value.toLowerCase()
    const items = this.availableListTarget.querySelectorAll('.professional-item')
    
    items.forEach(item => {
      const name = item.dataset.professionalName.toLowerCase()
      const specialties = item.dataset.professionalSpecialties.toLowerCase()
      
      if (name.includes(searchTerm) || specialties.includes(searchTerm)) {
        item.style.display = 'block'
      } else {
        item.style.display = 'none'
      }
    })
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
