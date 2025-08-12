import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  navigate(event) {
    // Não navegar se clicou em um link ou botão
    if (event.target.tagName === 'A' || event.target.tagName === 'BUTTON' || 
        event.target.closest('a') || event.target.closest('button')) {
      return
    }

    if (this.urlValue) {
      window.location.href = this.urlValue
    }
  }
}
