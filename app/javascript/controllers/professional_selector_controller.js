import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["searchInput", "professionalList", "hiddenInput", "loadingIndicator", "selectedList", "hiddenInputs"]

  connect() {
    this.selectedProfessionals = new Set()
    this.loadProfessionals()
  }

  search(event) {
    const query = event.target.value.trim()
    
    if (query.length < 2) {
      this.clearResults()
      return
    }

    this.showLoading()
    
    // Fazer requisição AJAX para buscar profissionais
    fetch(`/admin/agendas/search_professionals?search=${encodeURIComponent(query)}`, {
      method: 'GET',
      headers: {
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => response.json())
    .then(data => {
      this.hideLoading()
      this.renderSearchResults(data.professionals || [])
    })
    .catch(error => {
      this.hideLoading()
      this.showError('Erro ao buscar profissionais')
    })
  }

  async loadProfessionals() {
    try {
      const response = await fetch('/admin/agendas/search_professionals')
      const data = await response.json()
      
      this.renderSearchResults(data.professionals || [])
    } catch (error) {
    }
  }

  toggleProfessional(event) {
    const professionalId = event.target.dataset.professionalId
    const isChecked = event.target.checked

    if (isChecked) {
      this.addProfessional(professionalId)
    } else {
      this.removeProfessional(professionalId)
    }
    
    // Notificar o wizard controller sobre a mudança
    this.notifyWizardController()
  }

  selectProfessional(event) {
    const professionalId = event.target.dataset.professionalId
    
    // Limpar seleção anterior
    this.clearSelection()
    
    // Adicionar nova seleção
    this.addProfessional(professionalId)
    
    // Notificar o wizard controller sobre a mudança
    this.notifyWizardController()
  }

  addProfessional(professionalId) {
    // Verificar se já existe
    const existingInput = this.hiddenInputsTarget.querySelector(`input[data-professional-id="${professionalId}"]`)
    
    if (!existingInput) {
      const hiddenInput = document.createElement('input')
      hiddenInput.type = 'hidden'
      hiddenInput.name = 'agenda[professional_ids][]'
      hiddenInput.value = professionalId
      hiddenInput.dataset.professionalId = professionalId
      
      this.hiddenInputsTarget.appendChild(hiddenInput)
    }
  }

  removeProfessional(professionalId) {
    const inputToRemove = this.hiddenInputsTarget.querySelector(`input[data-professional-id="${professionalId}"]`)
    
    if (inputToRemove) {
      inputToRemove.remove()
    }
  }

  clearSelection() {
    this.hiddenInputsTarget.innerHTML = ''
  }

  renderSearchResults(professionals) {
    if (!this.hasProfessionalListTarget) return
    
    if (professionals.length === 0) {
      this.professionalListTarget.innerHTML = `
        <div class="p-4 text-center text-gray-500">
          <p class="text-sm">Nenhum profissional encontrado</p>
        </div>
      `
      return
    }

    const resultsHTML = professionals.map(professional => `
      <div class="professional-item flex items-center justify-between p-3 border-b border-gray-100 last:border-b-0 hover:bg-gray-50" data-professional-id="${professional.id}">
        <div class="flex items-center space-x-3">
          <div class="flex-shrink-0">
            <div class="h-8 w-8 rounded-full bg-gray-200 flex items-center justify-center">
              <span class="text-xs font-medium text-gray-600">${professional.name.charAt(0).toUpperCase()}</span>
            </div>
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-sm font-medium text-gray-900 truncate">
              ${professional.name}
            </p>
            <p class="text-xs text-gray-500 truncate">
              ${professional.specialties ? professional.specialties.join(', ') : 'Sem especialidades'}
            </p>
          </div>
        </div>
        <div class="flex items-center space-x-2">
          ${this.getCheckboxHTML(professional)}
        </div>
      </div>
    `).join('')

    this.professionalListTarget.innerHTML = resultsHTML
  }

  getCheckboxHTML(professional) {
    const isSelected = this.isProfessionalSelected(professional.id)
    
    if (this.isMultiple()) {
      return `
        <input 
          type="checkbox" 
          class="professional-checkbox rounded border-gray-300 text-brand-600 focus:ring-brand-500"
          ${isSelected ? 'checked' : ''}
          data-professional-id="${professional.id}"
          data-action="change->professional-selector#toggleProfessional"
        />
      `
    } else {
      return `
        <input 
          type="radio" 
          name="selected_professional"
          class="professional-radio rounded-full border-gray-300 text-brand-600 focus:ring-brand-500"
          ${isSelected ? 'checked' : ''}
          data-professional-id="${professional.id}"
          data-action="change->professional-selector#selectProfessional"
        />
      `
    }
  }

  isProfessionalSelected(professionalId) {
    return this.hiddenInputsTarget.querySelector(`input[data-professional-id="${professionalId}"]`) !== null
  }

  isMultiple() {
    return this.element.dataset.multiple === 'true'
  }

  clearResults() {
    if (!this.hasProfessionalListTarget) return
    
    this.professionalListTarget.innerHTML = `
      <div class="p-4 text-center text-gray-500">
        <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"></path>
        </svg>
        <p class="mt-2 text-sm">Digite para buscar profissionais</p>
      </div>
    `
  }

  showLoading() {
    if (this.hasLoadingIndicatorTarget) {
      this.loadingIndicatorTarget.classList.remove('hidden')
    }
    if (this.hasProfessionalListTarget) {
      this.professionalListTarget.style.opacity = '0.5'
    }
  }

  hideLoading() {
    if (this.hasLoadingIndicatorTarget) {
      this.loadingIndicatorTarget.classList.add('hidden')
    }
    if (this.hasProfessionalListTarget) {
      this.professionalListTarget.style.opacity = '1'
    }
  }

  showError(message) {
    if (!this.hasProfessionalListTarget) return
    
    this.professionalListTarget.innerHTML = `
      <div class="p-4 text-center text-red-500">
        <p class="text-sm">${message}</p>
      </div>
    `
  }

  notifyWizardController() {
    // Encontrar o controller do wizard no elemento pai
    const wizardElement = this.element.closest('[data-controller*="agendas-wizard"]')
    if (wizardElement) {
      const wizardController = this.application.getControllerForElementAndIdentifier(wizardElement, 'agendas-wizard')
      if (wizardController) {
        // Atualizar dados persistentes do wizard
        const selectedProfessionals = this.getSelectedProfessionalIds()
        wizardController.persistentData.professionals = selectedProfessionals
        wizardController.savePersistentData()
        wizardController.updateHiddenInputs()
      }
    }
  }

  getSelectedProfessionalIds() {
    const inputs = this.hiddenInputsTarget.querySelectorAll('input[data-professional-id]')
    return Array.from(inputs).map(input => input.dataset.professionalId)
  }
}

