import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar"]

  connect() {
    console.log("Header controller conectado")
  }

  toggleSidebar() {
    if (this.hasSidebarTarget) {
      this.sidebarTarget.classList.toggle("hidden")
    }
  }

  outside(event) {
    if (this.hasSidebarTarget && !this.element.contains(event.target)) {
      this.sidebarTarget.classList.add("hidden")
    }
  }
}
