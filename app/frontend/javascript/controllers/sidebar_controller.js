// app/frontend/javascript/controllers/sidebar_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "panel", "initialFocus", "trigger"]

  connect() {
    this.keyHandler = (e) => { if (e.key === 'Escape') this.close() }
  }

  toggle() {
    const html = document.documentElement
    const isOpen = html.classList.contains('sidebar-open')
    
    if (isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    document.documentElement.classList.add('sidebar-open')
    this.setAriaExpanded(true)
  }

  close() {
    document.documentElement.classList.remove('sidebar-open')
    this.setAriaExpanded(false)
  }

  setAriaExpanded(expanded) {
    if (this.hasTriggerTarget) {
      this.triggerTargets.forEach(t => t.setAttribute('aria-expanded', expanded.toString()))
    }
  }
}


