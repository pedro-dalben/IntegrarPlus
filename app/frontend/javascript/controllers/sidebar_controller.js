import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "panel", "initialFocus", "trigger"]

  connect() {
    console.log('Sidebar controller connected')
    console.log('Has overlay target:', this.hasOverlayTarget)
    console.log('Has panel target:', this.hasPanelTarget)
    console.log('Has trigger targets:', this.hasTriggerTarget)
    this.keyHandler = (e) => { if (e.key === 'Escape') this.close() }
  }

  open() {
    console.log('Sidebar open called')
    if (!this.hasOverlayTarget || !this.hasPanelTarget) {
      console.log('Missing targets - overlay:', this.hasOverlayTarget, 'panel:', this.hasPanelTarget)
      return
    }
    document.body.style.overflow = 'hidden'
    this.overlayTarget.classList.remove('hidden')
    this.panelTarget.classList.remove('-translate-x-full')
    this.panelTarget.classList.add('translate-x-0')
    this.panelTarget.setAttribute('aria-hidden', 'false')
    this.triggerTargets.forEach(t => t.setAttribute('aria-expanded', 'true'))
    const el = this.hasInitialFocusTarget ? this.initialFocusTarget : this.panelTarget.querySelector('a,button,input,select,textarea,[tabindex]')
    if (el) setTimeout(() => el.focus(), 50)
    document.addEventListener('keydown', this.keyHandler)
  }

  close() {
    if (!this.hasOverlayTarget || !this.hasPanelTarget) return
    document.body.style.overflow = ''
    this.overlayTarget.classList.add('hidden')
    this.panelTarget.classList.remove('translate-x-0')
    this.panelTarget.classList.add('-translate-x-full')
    this.panelTarget.setAttribute('aria-hidden', 'true')
    this.triggerTargets.forEach(t => t.setAttribute('aria-expanded', 'false'))
    document.removeEventListener('keydown', this.keyHandler)
  }
}


