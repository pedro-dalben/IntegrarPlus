// app/frontend/javascript/controllers/dropdown_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]
  static values = { open: { type: Boolean, default: false } }

  connect() {
    console.log("Dropdown controller connected")
  }

  toggle() {
    this.openValue = !this.openValue
    console.log('Dropdown toggled:', this.openValue)
  }

  close() {
    this.openValue = false
  }

  // Fechar quando clicar fora
  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  // Classes computadas
  get menuClasses() {
    return this.openValue ? 'block' : 'hidden'
  }
}
