import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "icon"]

  connect() {
    console.log('Accordion controller connected')
    const expanded = this.element.getAttribute('aria-expanded') === 'true'
    this.set(expanded)
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()
    console.log('Accordion toggle called')
    const expanded = this.element.getAttribute('aria-expanded') === 'true'
    this.set(!expanded)
  }

  set(v) {
    console.log('Setting accordion to:', v)
    this.element.setAttribute('aria-expanded', String(v))
    this.panelTargets.forEach(p => {
      p.classList.toggle('hidden', !v)
      console.log('Panel hidden:', !v)
    })
    this.iconTargets.forEach(i => i.classList.toggle('menu-item-arrow-active', v))
  }
}


