import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "arrow"]

  connect() {
    console.log("Dropdown controller connected")
    document.addEventListener("click", this.outside.bind(this))
  }

  disconnect() {
    console.log("Dropdown controller disconnected")
    document.removeEventListener("click", this.outside.bind(this))
  }

  toggle() {
    console.log("Dropdown toggle clicked")
    if (this.panelTarget.classList.contains("hidden")) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    console.log("Opening dropdown")
    this.panelTarget.classList.remove("hidden")
    if (this.hasArrowTarget) {
      this.arrowTarget.style.transform = "rotate(180deg)"
    }
  }

  close() {
    console.log("Closing dropdown")
    this.panelTarget.classList.add("hidden")
    if (this.hasArrowTarget) {
      this.arrowTarget.style.transform = "rotate(0deg)"
    }
  }

  outside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }
}
