import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Header component controller connected")
  }

  toggleSidebar() {
    this.dispatch("sidebar-toggle")
  }
}
