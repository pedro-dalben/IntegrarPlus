import { Controller } from "@hotwired/stimulus"

console.log("🔧 Carregando WizardController...")

export default class extends Controller {
  static targets = ["step", "previousBtn", "nextBtn", "activateBtn", "tab", "currentStepInput"]
  
  static values = { currentStep: String }

  connect() {
    console.log("🔧 WizardController conectado")
    // Permite inicializar pelo valor vindo do HTML (ex.: edit com ?step=...)
    if (!this.hasCurrentStepValue || !this.currentStepValue) {
      this.currentStepValue = "metadata"
    }
    this.showStep(this.currentStepValue)
    this.updateNavigation()
    this.updateTabs()
    this.initializeDataPersistence()
    console.log("🔧 Navegação atualizada, step atual:", this.currentStepValue)
  }

  initializeDataPersistence() {
    // Inicializar dados persistentes
    this.persistentData = {
      professionals: []
    }
    
    // Verificar se há dados salvos no localStorage
    const savedData = localStorage.getItem('agenda_wizard_data')
    if (savedData) {
      try {
        this.persistentData = JSON.parse(savedData)
      } catch (e) {
        console.warn('Erro ao carregar dados persistentes:', e)
      }
    }
  }

  savePersistentData() {
    localStorage.setItem('agenda_wizard_data', JSON.stringify(this.persistentData))
  }

  addProfessional(professionalId) {
    if (!this.persistentData.professionals.includes(professionalId)) {
      this.persistentData.professionals.push(professionalId)
      this.savePersistentData()
      this.updateHiddenInputs()
    }
  }

  removeProfessional(professionalId) {
    this.persistentData.professionals = this.persistentData.professionals.filter(id => id !== professionalId)
    this.savePersistentData()
    this.updateHiddenInputs()
  }

  updateHiddenInputs() {
    // Remover inputs existentes
    const existingInputs = this.element.querySelectorAll('input[name="agenda[professional_ids][]"]')
    existingInputs.forEach(input => input.remove())
    
    // Adicionar novos inputs
    this.persistentData.professionals.forEach(professionalId => {
      const input = document.createElement('input')
      input.type = 'hidden'
      input.name = 'agenda[professional_ids][]'
      input.value = professionalId
      this.element.appendChild(input)
    })
  }

  saveCurrentStepData() {
    // Salvar dados específicos da etapa atual
    if (this.currentStepValue === 'professionals') {
      // Coletar profissionais selecionados da etapa de profissionais
      const selectedProfessionals = this.collectSelectedProfessionals()
      this.persistentData.professionals = selectedProfessionals
      this.savePersistentData()
      this.updateHiddenInputs()
    }
  }

  collectSelectedProfessionals() {
    const professionals = []
    
    // Verificar checkboxes selecionados
    const checkboxes = this.element.querySelectorAll('input[type="checkbox"][data-professional-id]:checked')
    checkboxes.forEach(checkbox => {
      const professionalId = checkbox.dataset.professionalId
      if (professionalId) {
        professionals.push(professionalId)
      }
    })
    
    return professionals
  }

  nextStep() {
    console.log("🔧 nextStep chamado, step atual:", this.currentStepValue)
    const steps = ["metadata", "professionals", "working_hours", "review"]
    const currentIndex = steps.indexOf(this.currentStepValue)
    
    if (currentIndex < steps.length - 1) {
      // Salvar dados da etapa atual antes de avançar
      this.saveCurrentStepData()
      
      this.currentStepValue = steps[currentIndex + 1]
      console.log("🔧 Mudando para step:", this.currentStepValue)
      this.showStep(this.currentStepValue)
      this.updateNavigation()
      this.updateTabs()
      this.updateStepInput()
      
      // Atualizar inputs hidden após mudança de etapa
      this.updateHiddenInputs()
    }
  }

  previousStep() {
    const steps = ["metadata", "professionals", "working_hours", "review"]
    const currentIndex = steps.indexOf(this.currentStepValue)
    
    if (currentIndex > 0) {
      this.currentStepValue = steps[currentIndex - 1]
      this.showStep(this.currentStepValue)
      this.updateNavigation()
      this.updateTabs()
      this.updateStepInput()
    }
  }

  showStep(stepName) {
    this.stepTargets.forEach(step => {
      if (step.dataset.step === stepName) {
        step.classList.remove("hidden")
        // Restaurar dados específicos da etapa
        this.restoreStepData(stepName)
      } else {
        step.classList.add("hidden")
      }
    })
  }

  restoreStepData(stepName) {
    if (stepName === 'professionals') {
      // Restaurar seleção de profissionais
      this.restoreProfessionalSelection()
      // Garantir que os inputs hidden sejam criados
      this.updateHiddenInputs()
    }
  }

  restoreProfessionalSelection() {
    // Marcar checkboxes dos profissionais selecionados
    this.persistentData.professionals.forEach(professionalId => {
      const checkbox = this.element.querySelector(`input[type="checkbox"][data-professional-id="${professionalId}"]`)
      if (checkbox) {
        checkbox.checked = true
      }
    })
  }

  // Métodos para gerenciar busca de profissionais
  searchProfessionals(event) {
    const query = event.target.value.trim()
    
    if (query.length < 2) {
      this.clearProfessionalResults()
      return
    }

    this.showProfessionalLoading()
    
    fetch(`/admin/agendas/search_professionals?search=${encodeURIComponent(query)}`, {
      method: 'GET',
      headers: {
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => response.json())
    .then(data => {
      this.hideProfessionalLoading()
      this.renderProfessionalResults(data.professionals || [])
    })
    .catch(error => {
      console.error('Erro ao buscar profissionais:', error)
      this.hideProfessionalLoading()
      this.showProfessionalError('Erro ao buscar profissionais')
    })
  }

  renderProfessionalResults(professionals) {
    const professionalList = this.element.querySelector('[data-professional-selector-target="professionalList"]')
    if (!professionalList) return
    
    if (professionals.length === 0) {
      professionalList.innerHTML = `
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
          <input 
            type="checkbox" 
            class="professional-checkbox rounded border-gray-300 text-brand-600 focus:ring-brand-500"
            data-professional-id="${professional.id}"
            data-action="change->agendas-wizard#toggleProfessional"
          />
        </div>
      </div>
    `).join('')

    professionalList.innerHTML = resultsHTML
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

  clearProfessionalResults() {
    const professionalList = this.element.querySelector('[data-professional-selector-target="professionalList"]')
    if (!professionalList) return
    
    professionalList.innerHTML = `
      <div class="p-4 text-center text-gray-500">
        <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"></path>
        </svg>
        <p class="mt-2 text-sm">Digite para buscar profissionais</p>
      </div>
    `
  }

  showProfessionalLoading() {
    const professionalList = this.element.querySelector('[data-professional-selector-target="professionalList"]')
    if (professionalList) {
      professionalList.style.opacity = '0.5'
    }
  }

  hideProfessionalLoading() {
    const professionalList = this.element.querySelector('[data-professional-selector-target="professionalList"]')
    if (professionalList) {
      professionalList.style.opacity = '1'
    }
  }

  showProfessionalError(message) {
    const professionalList = this.element.querySelector('[data-professional-selector-target="professionalList"]')
    if (!professionalList) return
    
    professionalList.innerHTML = `
      <div class="p-4 text-center text-red-500">
        <p class="text-sm">${message}</p>
      </div>
    `
  }

  updateNavigation() {
    const steps = ["metadata", "professionals", "working_hours", "review"]
    const currentIndex = steps.indexOf(this.currentStepValue)
    
    // Update previous button
    if (currentIndex === 0) {
      this.previousBtnTarget.classList.add("hidden")
    } else {
      this.previousBtnTarget.classList.remove("hidden")
    }
    
    // Update next button
    if (currentIndex === steps.length - 1) {
      this.nextBtnTarget.classList.add("hidden")
      if (this.hasActivateBtnTarget) {
        this.activateBtnTarget.classList.remove("hidden")
      }
    } else {
      this.nextBtnTarget.classList.remove("hidden")
      if (this.hasActivateBtnTarget) {
        this.activateBtnTarget.classList.add("hidden")
      }
    }
  }

  updateTabs() {
    if (!this.hasTabTarget) return
    this.tabTargets.forEach(tab => {
      const active = tab.dataset.step === this.currentStepValue
      tab.classList.toggle('border-blue-500', active)
      tab.classList.toggle('border-transparent', !active)
      const span = tab.querySelector('span')
      if (span) {
        span.classList.toggle('text-blue-600', active)
        span.classList.toggle('dark:text-blue-400', active)
        span.classList.toggle('text-gray-500', !active)
        span.classList.toggle('dark:text-gray-400', !active)
      }
    })
  }

  currentStepValueChanged() {
    this.updateNavigation()
    this.updateTabs()
    this.updateStepInput()
  }

  goToStep(event) {
    event.preventDefault()
    const target = event.currentTarget
    if (!target) return
    const step = target.dataset.step
    if (!step) return
    this.currentStepValue = step
    this.showStep(step)
    this.updateNavigation()
    this.updateTabs()
    this.updateStepInput()
  }

  updateStepInput() {
    if (this.hasCurrentStepInputTarget) {
      this.currentStepInputTarget.value = this.currentStepValue
    } else {
      const input = this.element.querySelector('input[name="step"]')
      if (input) input.value = this.currentStepValue
    }
  }

  clearPersistentData() {
    localStorage.removeItem('agenda_wizard_data')
    this.persistentData = {
      professionals: []
    }
  }

  // Método para ser chamado quando a agenda for salva com sucesso
  onAgendaSaved() {
    this.clearPersistentData()
  }

  // Método para garantir que os dados sejam persistidos antes do envio
  ensureDataPersistence() {
    // Salvar dados da etapa atual
    this.saveCurrentStepData()
    
    // Garantir que os inputs hidden existam
    this.updateHiddenInputs()
    
    // Adicionar professional_ids como parâmetro separado
    this.addProfessionalIdsParameter()
    
    // Log para debug
    const hiddenInputs = this.element.querySelectorAll('input[name="agenda[professional_ids][]"]')
    console.log('Inputs hidden antes do envio:', hiddenInputs.length)
    hiddenInputs.forEach((input, index) => {
      console.log(`Input ${index + 1}:`, input.name, input.value)
    })
  }

  addProfessionalIdsParameter() {
    // Remover parâmetro existente se houver
    const existingParam = this.element.querySelector('input[name="professional_ids"]')
    if (existingParam) {
      existingParam.remove()
    }

    // Adicionar professional_ids como parâmetro separado
    if (this.persistentData.professionals.length > 0) {
      const form = this.element.querySelector('form')
      if (form) {
        this.persistentData.professionals.forEach(professionalId => {
          const input = document.createElement('input')
          input.type = 'hidden'
          input.name = 'professional_ids[]'
          input.value = professionalId
          form.appendChild(input)
        })
        console.log('Professional IDs adicionados como parâmetros separados:', this.persistentData.professionals)
      }
    }
  }
}
