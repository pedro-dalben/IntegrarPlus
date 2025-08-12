import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["companyField", "cnpjField"]
  static values = { 
    contractTypes: Array,
    currentType: String 
  }

  connect() {
    this.updateFields()
  }

  contractTypeChanged(event) {
    this.currentTypeValue = event.target.value
    this.updateFields()
  }

  updateFields() {
    if (!this.currentTypeValue) {
      this.hideAllFields()
      return
    }

    const contractType = this.contractTypesValue.find(type => type.id.toString() === this.currentTypeValue)
    
    if (!contractType) {
      this.hideAllFields()
      return
    }

    if (contractType.requires_company) {
      this.showField(this.companyFieldTarget)
    } else {
      this.hideField(this.companyFieldTarget)
    }

    if (contractType.requires_cnpj) {
      this.showField(this.cnpjFieldTarget)
    } else {
      this.hideField(this.cnpjFieldTarget)
      this.clearField(this.cnpjFieldTarget)
    }
  }

  showField(field) {
    field.style.display = 'block'
    field.setAttribute('aria-hidden', 'false')
    field.classList.remove('opacity-0', 'pointer-events-none')
    field.classList.add('opacity-100')
  }

  hideField(field) {
    field.style.display = 'none'
    field.setAttribute('aria-hidden', 'true')
    field.classList.remove('opacity-100')
    field.classList.add('opacity-0', 'pointer-events-none')
  }

  hideAllFields() {
    this.companyFieldTarget && this.hideField(this.companyFieldTarget)
    this.cnpjFieldTarget && this.hideField(this.cnpjFieldTarget)
  }

  clearField(field) {
    const input = field.querySelector('input, textarea, select')
    if (input) {
      input.value = ''
    }
  }
}
