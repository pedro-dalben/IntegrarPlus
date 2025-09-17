import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["searchInput", "professionalList", "hiddenInput", "loadingIndicator"]

  connect() {
    console.log("ProfessionalSelectorController conectado")
  }

  search(event) {
    const query = event.target.value.trim()
    
    if (query.length < 2) {
      this.clearResults()
      return
    }

    this.showLoading()
    
    // Fazer requisição AJAX para buscar profissionais
    fetch(`/api/professionals/search?q=${encodeURIComponent(query)}`, {
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
      console.error('Erro ao buscar profissionais:', error)
      this.hideLoading()
      this.showError('Erro ao buscar profissionais')
    })
  }

  toggleProfessional(event) {
    const professionalId = event.target.dataset.professionalId
    const isChecked = event.target.checked

    if (isChecked) {
      this.addProfessional(professionalId)
    } else {
      this.removeProfessional(professionalId)
    }
  }

  selectProfessional(event) {
    const professionalId = event.target.dataset.professionalId
    
    // Limpar seleção anterior
    this.clearSelection()
    
    // Adicionar nova seleção
    this.addProfessional(professionalId)
  }

  addProfessional(professionalId) {
    // Verificar se já existe
    const existingInput = this.hiddenInputTargets.find(input => 
      input.dataset.professionalId === professionalId
    )
    
    if (!existingInput) {
      const hiddenInput = document.createElement('input')
      hiddenInput.type = 'hidden'
      hiddenInput.name = 'agenda[professional_ids][]'
      hiddenInput.value = professionalId
      hiddenInput.dataset.professionalSelectorTarget = 'hiddenInput'
      hiddenInput.dataset.professionalId = professionalId
      
      this.element.appendChild(hiddenInput)
    }
  }

  removeProfessional(professionalId) {
    const inputToRemove = this.hiddenInputTargets.find(input => 
      input.dataset.professionalId === professionalId
    )
    
    if (inputToRemove) {
      inputToRemove.remove()
    }
  }

  clearSelection() {
    this.hiddenInputTargets.forEach(input => input.remove())
  }

  renderSearchResults(professionals) {
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
            <img 
              src="${professional.avatar_url || '/default-avatar.png'}" 
              alt="${professional.full_name}"
              class="h-8 w-8 rounded-full object-cover"
            />
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-sm font-medium text-gray-900 truncate">
              ${professional.full_name}
            </p>
            <p class="text-xs text-gray-500 truncate">
              ${professional.email}
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
    return this.hiddenInputTargets.some(input => 
      input.dataset.professionalId === professionalId
    )
  }

  isMultiple() {
    return this.element.dataset.multiple === 'true'
  }

  clearResults() {
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
    this.loadingIndicatorTarget.classList.remove('hidden')
    this.professionalListTarget.style.opacity = '0.5'
  }

  hideLoading() {
    this.loadingIndicatorTarget.classList.add('hidden')
    this.professionalListTarget.style.opacity = '1'
  }

  showError(message) {
    this.professionalListTarget.innerHTML = `
      <div class="p-4 text-center text-red-500">
        <p class="text-sm">${message}</p>
      </div>
    `
  }
}

