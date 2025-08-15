// app/frontend/javascript/controllers/menu_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "trigger"]
  static values = { open: Boolean }

  connect() {
    this.boundCloseOnClickOutside = this.closeOnClickOutside.bind(this)
    this.boundCloseOnEscape = this.closeOnEscape.bind(this)
  }

  disconnect() {
    this.removeEventListeners()
  }

  toggle() {
    if (this.openValue) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.openValue = true
    this.element.classList.remove('hidden')
    this.element.classList.add('flex')
    this.setAriaExpanded(true)
    this.addEventListeners()
  }

  close() {
    this.openValue = false
    this.element.classList.remove('flex')
    this.element.classList.add('hidden')
    this.setAriaExpanded(false)
    this.removeEventListeners()
  }

  closeOnClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  closeOnEscape(event) {
    if (event.key === 'Escape') {
      this.close()
    }
  }

  setAriaExpanded(expanded) {
    if (this.hasTriggerTarget) {
      this.triggerTargets.forEach(el => el.setAttribute('aria-expanded', expanded.toString()))
    }
  }

  addEventListeners() {
    document.addEventListener('click', this.boundCloseOnClickOutside)
    document.addEventListener('keydown', this.boundCloseOnEscape)
  }

  removeEventListeners() {
    document.removeEventListener('click', this.boundCloseOnClickOutside)
    document.removeEventListener('keydown', this.boundCloseOnEscape)
  }
}


