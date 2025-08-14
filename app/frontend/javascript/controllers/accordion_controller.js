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
      if (v) {
        p.classList.remove('hidden')
        p.style.maxHeight = '200px'
        p.style.opacity = '1'
      } else {
        p.classList.add('hidden')
        p.style.maxHeight = '0'
        p.style.opacity = '0'
      }
      console.log('Panel hidden:', !v)
    })
    this.iconTargets.forEach(i => i.classList.toggle('menu-item-arrow-active', v))
  }
}


