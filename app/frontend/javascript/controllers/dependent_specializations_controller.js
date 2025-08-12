import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["specialitySelect", "specializationSelect"]
  static values = { 
    endpoint: String,
    currentSpecializations: Array 
  }

  connect() {
    this.updateSpecializations()
  }

  specialityChanged() {
    this.updateSpecializations()
  }

  async updateSpecializations() {
    const selectedSpecialityIds = this.getSelectedSpecialityIds()
    
    if (selectedSpecialityIds.length === 0) {
      this.clearSpecializations()
      return
    }

    try {
      const response = await this.fetchSpecializations(selectedSpecialityIds)
      const specializations = await response.json()
      
      this.updateSpecializationOptions(specializations)
      this.preserveValidSelections(specializations)
    } catch (error) {
      console.error('Erro ao carregar especializações:', error)
    }
  }

  getSelectedSpecialityIds() {
    const select = this.specialitySelectTarget
    if (select.multiple) {
      return Array.from(select.selectedOptions).map(option => option.value)
    } else {
      return select.value ? [select.value] : []
    }
  }

  async fetchSpecializations(specialityIds) {
    const params = new URLSearchParams()
    specialityIds.forEach(id => params.append('speciality_ids[]', id))
    
    return fetch(`${this.endpointValue}?${params.toString()}`, {
      headers: {
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
  }

  updateSpecializationOptions(specializations) {
    const select = this.specializationSelectTarget
    const currentValue = select.value
    
    // Limpar opções existentes (exceto a primeira se for placeholder)
    const placeholderOption = select.querySelector('option[value=""]')
    select.innerHTML = ''
    if (placeholderOption) {
      select.appendChild(placeholderOption)
    }
    
    // Adicionar novas opções
    specializations.forEach(spec => {
      const option = document.createElement('option')
      option.value = spec.id
      option.textContent = spec.name
      select.appendChild(option)
    })
    
    // Restaurar valor se ainda for válido
    if (currentValue && specializations.some(s => s.id.toString() === currentValue)) {
      select.value = currentValue
    } else {
      select.value = ''
    }
    
    // Re-inicializar tom-select se existir
    this.reinitializeTomSelect()
  }

  preserveValidSelections(specializations) {
    const select = this.specializationSelectTarget
    const validIds = specializations.map(s => s.id.toString())
    
    if (select.multiple) {
      const selectedOptions = Array.from(select.selectedOptions)
      const validSelections = selectedOptions.filter(option => 
        validIds.includes(option.value)
      )
      
      // Desmarcar opções inválidas
      selectedOptions.forEach(option => {
        if (!validIds.includes(option.value)) {
          option.selected = false
        }
      })
      
      // Re-inicializar tom-select se existir
      this.reinitializeTomSelect()
    }
  }

  clearSpecializations() {
    const select = this.specializationSelectTarget
    
    if (select.multiple) {
      Array.from(select.selectedOptions).forEach(option => {
        option.selected = false
      })
    } else {
      select.value = ''
    }
    
    // Limpar opções
    const placeholderOption = select.querySelector('option[value=""]')
    select.innerHTML = ''
    if (placeholderOption) {
      select.appendChild(placeholderOption)
    }
    
    this.reinitializeTomSelect()
  }

  reinitializeTomSelect() {
    // Se o select tem tom-select, re-inicializar
    const tomSelectInstance = this.specializationSelectTarget.tomselect
    if (tomSelectInstance) {
      tomSelectInstance.refreshOptions()
      tomSelectInstance.refreshItems()
    }
  }
}
