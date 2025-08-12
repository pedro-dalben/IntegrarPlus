import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { 
    autoDismiss: { type: Boolean, default: true },
    duration: { type: Number, default: 5000 }
  }

  connect() {
    if (this.autoDismissValue) {
      this.startAutoDismiss()
    }
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  startAutoDismiss() {
    this.timeout = setTimeout(() => {
      this.dismiss()
    }, this.durationValue)
  }

  dismiss() {
    this.element.classList.add('opacity-0', 'transform', 'scale-95')
    
    setTimeout(() => {
      this.element.remove()
    }, 200)
  }

  dismissNow() {
    this.dismiss()
  }
}
