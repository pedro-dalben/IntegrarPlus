import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
  static targets = ["searchInput", "professionalList", "hiddenInput", "loadingIndicator", "selectedList", "hiddenInputs", "selectedProfessionalsContainer", "tomselect"]

  connect() {
    this.selectedProfessionals = new Set()
    this.professionalsData = {}
    // Não carregar lista; usamos apenas Tom Select como busca
    const selectEl = this.hasTomselectTarget ? this.tomselectTarget : this.element.querySelector('select[data-professional-selector-target="tomselect"]')
    if (selectEl && !selectEl.tomSelect) {
      const url = selectEl.dataset.url || "/admin/agendas/search_professionals"
      const allowMultiple = this.element.dataset.multiple === 'true'
      this.tomSelect = new TomSelect(selectEl, {
        plugins: ["dropdown_input"],
        valueField: "id",
        labelField: "name",
        searchField: "name",
        preload: false,
        shouldLoad: (query) => (query || '').trim().length >= 2,
        maxItems: allowMultiple ? null : 1,
        load: (query, callback) => {
          const u = `${url}?search=${encodeURIComponent(query || "")}`
          fetch(u, { headers: { Accept: "application/json" } })
            .then((r) => r.json())
            .then((json) => callback(json.professionals || []))
            .catch(() => callback())
        },
        onItemAdd: (value) => {
          this.syncAddSingle(value, this.tomSelect.options)
          this.updateSelectedProfessionalsList()
          this.notifyWizardController()
          this.tomSelect.clear(true)
        }
      })
      selectEl.tomSelect = this.tomSelect
      // Pré-popular profissionais já salvos (opções com selected)
      // Se houver inputs ocultos pré-carregados, popular lista visual
      const presetInputs = this.hiddenInputsTarget.querySelectorAll('input[data-professional-id]')
      presetInputs.forEach((input) => this.syncAddSingle(input.dataset.professionalId, this.tomSelect.options))
      this.updateSelectedProfessionalsList()
    }
    this.updateSelectedProfessionalsList()
  }

  syncFromTomSelect(event) {
    const selectElement = event.target
    const tom = selectElement && selectElement.tomSelect
    if (!tom) return

    this.syncFromTomSelectValues(tom.getValue(), tom.options)
  }

  syncFromTomSelectValues(values, optionsMap = {}) {
    const selectedIds = Array.isArray(values) ? values : (values ? [values] : [])

    this.hiddenInputsTarget.innerHTML = ''

    selectedIds.forEach((id) => {
      this.syncAddSingle(id, optionsMap)
    })

    this.updateSelectedProfessionalsList()
    this.notifyWizardController()
  }

  syncAddSingle(id, optionsMap = {}) {
    const optionData = optionsMap && optionsMap[id] ? optionsMap[id] : {}
    const name = optionData.name || optionData.text || optionData.label || ''
    const specialties = optionData.specialties || []

    if (!this.hiddenInputsTarget.querySelector(`input[data-professional-id="${id}"]`)) {
      const hiddenInput = document.createElement('input')
      hiddenInput.type = 'hidden'
      hiddenInput.name = 'agenda[professional_ids][]'
      hiddenInput.value = id
      hiddenInput.dataset.professionalId = id
      if (name) hiddenInput.dataset.professionalName = name
      if (specialties && specialties.length > 0) hiddenInput.dataset.professionalSpecialties = Array.isArray(specialties) ? specialties.join(', ') : String(specialties)
      this.hiddenInputsTarget.appendChild(hiddenInput)
    }

    this.professionalsData[id] = {
      id,
      name,
      specialties: Array.isArray(specialties) ? specialties : String(specialties || '').split(',').map(s => s.trim()).filter(Boolean)
    }
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
      const response = await fetch('/admin/agendas/search_professionals', {
        method: 'GET',
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        }
      })
      const data = await response.json()
      
      this.renderSearchResults(data.professionals || [])
    } catch (error) {
    }
  }

  selectAllApt() {
    this.selectAll()
  }

  selectAll() {
    if (!this.hasProfessionalListTarget) return
    const checkboxes = this.professionalListTarget.querySelectorAll('.professional-checkbox')
    checkboxes.forEach(cb => {
      const professionalId = cb.dataset.professionalId
      cb.checked = true
      const data = this.professionalsData[professionalId]
      this.addProfessional(professionalId, data)
    })
    this.updateSelectedProfessionalsList()
    this.notifyWizardController()
  }

  toggleProfessional(event) {
    const professionalId = event.target.dataset.professionalId
    const isChecked = event.target.checked

    if (isChecked) {
      this.addProfessional(professionalId)
    } else {
      this.removeProfessional(professionalId)
    }
    
    this.updateSelectedProfessionalsList()
    
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

  addProfessional(professionalId, professionalData = null) {
    const existingInput = this.hiddenInputsTarget.querySelector(`input[data-professional-id="${professionalId}"]`)
    
    if (!existingInput) {
      const hiddenInput = document.createElement('input')
      hiddenInput.type = 'hidden'
      hiddenInput.name = 'agenda[professional_ids][]'
      hiddenInput.value = professionalId
      hiddenInput.dataset.professionalId = professionalId
      const data = professionalData || this.professionalsData[professionalId] || {}
      if (data && data.name) hiddenInput.dataset.professionalName = data.name
      if (data && data.specialties) hiddenInput.dataset.professionalSpecialties = (data.specialties || []).join(', ')
      
      this.hiddenInputsTarget.appendChild(hiddenInput)
    }
    
    if (professionalData) {
      this.professionalsData[professionalId] = professionalData
    }
  }

  removeProfessional(professionalId) {
    const inputToRemove = this.hiddenInputsTarget.querySelector(`input[data-professional-id="${professionalId}"]`)
    
    if (inputToRemove) {
      inputToRemove.remove()
    }
    
    delete this.professionalsData[professionalId]
  }
  
  removeProfessionalFromSelected(event) {
    const professionalId = event.currentTarget.dataset.professionalId
    this.removeProfessional(professionalId)
    this.updateSelectedProfessionalsList()
    
    const checkbox = this.professionalListTarget.querySelector(`input[data-professional-id="${professionalId}"]`)
    if (checkbox) {
      checkbox.checked = false
    }
    
    this.notifyWizardController()
  }

  clearSelection() {
    this.hiddenInputsTarget.innerHTML = ''
  }

  renderSearchResults(professionals) {
    if (!this.hasProfessionalListTarget) return
    
    professionals.forEach(prof => {
      this.professionalsData[prof.id] = prof
    })
    
    if (professionals.length === 0) {
      this.professionalListTarget.innerHTML = `
        <div class="p-4 text-center text-gray-500">
          <p class="text-sm">Nenhum profissional encontrado</p>
        </div>
      `
      return
    }

    const resultsHTML = professionals.map(professional => {
      const specialties = professional.specialties ? professional.specialties.join(', ') : 'Sem especialidades'
      const name = professional.name || ''
      return `
      <div class="professional-item flex items-center justify-between p-3 border-b border-gray-100 last:border-b-0 hover:bg-gray-50"
           data-professional-id="${professional.id}"
           data-professional-name="${name.replace(/"/g, '&quot;')}"
           data-professional-specialties="${specialties.replace(/"/g, '&quot;')}">
        <div class="flex items-center space-x-3">
          <div class="flex-shrink-0">
            <div class="h-8 w-8 rounded-full bg-gray-200 flex items-center justify-center">
              <span class="text-xs font-medium text-gray-600">${name.charAt(0).toUpperCase()}</span>
            </div>
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-sm font-medium text-gray-900 truncate">
              ${name}
            </p>
            <p class="text-xs text-gray-500 truncate">
              ${specialties}
            </p>
          </div>
        </div>
        <div class="flex items-center space-x-2">
          ${this.getCheckboxHTML(professional)}
        </div>
      </div>
    `
    }).join('')

    this.professionalListTarget.innerHTML = resultsHTML
  }
  
  updateSelectedProfessionalsList() {
    if (!this.hasSelectedProfessionalsContainerTarget) return
    
    const selectedIds = Array.from(this.hiddenInputsTarget.querySelectorAll('input[data-professional-id]'))
      .map(input => input.dataset.professionalId)
    
    if (selectedIds.length === 0) {
      this.selectedProfessionalsContainerTarget.innerHTML = `
        <div class="text-sm text-gray-500 text-center py-2">
          Nenhum profissional selecionado
        </div>
      `
      return
    }
    
    const selectedHTML = selectedIds.map(id => {
      let professional = this.professionalsData[id]
      if (!professional) {
        const input = this.hiddenInputsTarget.querySelector(`input[data-professional-id="${id}"]`)
        const name = input?.dataset.professionalName || ''
        const specialties = (input?.dataset.professionalSpecialties || '').split(',').map(s => s.trim()).filter(Boolean)
        professional = { id, name, specialties }
      }
      
      return `
        <div class="flex items-center justify-between p-2 bg-white rounded-lg border border-gray-200 mb-2">
          <div class="flex items-center space-x-2 flex-1 min-w-0">
            <div class="flex-shrink-0">
              <div class="h-8 w-8 rounded-full bg-blue-100 flex items-center justify-center">
                <span class="text-xs font-medium text-blue-600">${(professional.name || '').charAt(0).toUpperCase()}</span>
              </div>
            </div>
            <div class="flex-1 min-w-0">
              <p class="text-sm font-medium text-gray-900 truncate">
                ${professional.name}
              </p>
              <p class="text-xs text-gray-500 truncate">
                ${professional.specialties && professional.specialties.length > 0 ? professional.specialties.join(', ') : 'Sem especialidades'}
              </p>
            </div>
          </div>
          <button 
            type="button"
            class="ml-2 text-red-600 hover:text-red-800 flex-shrink-0"
            data-action="click->professional-selector#removeProfessionalFromSelected"
            data-professional-id="${id}">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
          </button>
        </div>
      `
    }).join('')
    
    this.selectedProfessionalsContainerTarget.innerHTML = selectedHTML
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
    const wizardElement = this.element.closest('[data-controller*="agendas--wizard"]')
    if (wizardElement) {
      const wizardController = this.application.getControllerForElementAndIdentifier(wizardElement, 'agendas--wizard')
      if (wizardController) {
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

