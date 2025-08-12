import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel"]

  toggle() {
    if (!this.hasPanelTarget) return
    this.panelTarget.classList.toggle('hidden')
    const expanded = this.panelTarget.classList.contains('hidden') ? 'false' : 'true'
    this.element.querySelectorAll('[aria-haspopup="menu"]').forEach(el => el.setAttribute('aria-expanded', expanded))
  }
}


