import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "trigger"]

  connect() {
    this.boundCloseOnClickOutside = this.closeOnClickOutside.bind(this)
    this.boundCloseOnEscape = this.closeOnEscape.bind(this)
  }

  disconnect() {
    this.removeEventListeners()
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()
    
    if (!this.hasPanelTarget) return
    
    const isHidden = this.panelTarget.classList.contains('hidden')
    
    if (isHidden) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    this.panelTarget.classList.remove('hidden')
    this.setAriaExpanded(true)
    this.addEventListeners()
  }

  close() {
    this.panelTarget.classList.add('hidden')
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
    const triggers = this.hasTriggerTarget ? [this.triggerTarget] : this.element.querySelectorAll('[aria-haspopup="menu"]')
    triggers.forEach(el => el.setAttribute('aria-expanded', expanded.toString()))
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


