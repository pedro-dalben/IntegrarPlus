import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "arrow"]

  toggle() {
    if (this.menuTarget.classList.contains("hidden")) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    this.menuTarget.classList.remove("hidden")
    this.arrowTarget.style.transform = "rotate(180deg)"
  }

  close() {
    this.menuTarget.classList.add("hidden")
    this.arrowTarget.style.transform = "rotate(0deg)"
  }

  // Fechar dropdown quando clicar fora
  outside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }
}
