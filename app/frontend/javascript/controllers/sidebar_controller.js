import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "panel", "initialFocus", "trigger"]

  connect() {
    this.keyHandler = (e) => { if (e.key === 'Escape') this.close() }
  }

  open() {
    if (!this.hasOverlayTarget || !this.hasPanelTarget) return
    document.body.style.overflow = 'hidden'
    this.overlayTarget.classList.remove('hidden')
    this.panelTarget.style.transform = 'translateX(0)'
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
    this.panelTarget.style.transform = 'translateX(-100%)'
    this.panelTarget.setAttribute('aria-hidden', 'true')
    this.triggerTargets.forEach(t => t.setAttribute('aria-expanded', 'false'))
    document.removeEventListener('keydown', this.keyHandler)
  }
}


