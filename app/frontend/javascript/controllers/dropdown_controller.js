// app/frontend/javascript/controllers/dropdown_controller.js
import { Controller } from "@hotwired/stimulus"
import { useClickOutside } from "stimulus-use"

export default class extends Controller {
  static targets = ["panel"]

  connect() {
    useClickOutside(this)
  }

  toggle() {
    if (this.isOpen()) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.render(true)
    this.setAriaExpanded(true)
  }

  close() {
    this.render(false)
    this.setAriaExpanded(false)
  }

  render(show) {
    if (this.hasPanelTarget) {
      if (show) {
        this.panelTarget.style.display = 'block'
      } else {
        this.panelTarget.style.display = 'none'
      }
    }
  }

  isOpen() {
    return this.hasPanelTarget && this.panelTarget.style.display !== 'none'
  }

  setAriaExpanded(expanded) {
    const button = this.element.querySelector('button')
    if (button) {
      button.setAttribute('aria-expanded', expanded.toString())
    }
  }

  clickOutside(event) {
    this.close()
  }
}
