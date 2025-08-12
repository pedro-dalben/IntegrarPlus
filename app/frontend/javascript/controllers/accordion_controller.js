import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "icon"]

  connect() {
    const expanded = this.element.getAttribute('aria-expanded') === 'true'
    this.set(expanded)
  }

  toggle() {
    const expanded = this.element.getAttribute('aria-expanded') === 'true'
    this.set(!expanded)
  }

  set(v) {
    this.element.setAttribute('aria-expanded', String(v))
    this.panelTargets.forEach(p => p.classList.toggle('hidden', !v))
    this.iconTargets.forEach(i => i.classList.toggle('menu-item-arrow-active', v))
  }
}


