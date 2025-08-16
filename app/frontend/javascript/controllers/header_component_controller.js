import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { darkMode: { type: Boolean, default: false } }

  connect() {
    console.log("Header component controller connected")
    this.darkModeValue = JSON.parse(localStorage.getItem('darkMode') || 'false')
  }

  disconnect() {
    localStorage.setItem('darkMode', JSON.stringify(this.darkModeValue))
  }

  toggleSidebar() {
    this.dispatch("sidebar-toggle")
  }

  toggleDarkMode() {
    this.darkModeValue = !this.darkModeValue
    console.log('Dark mode toggled:', this.darkModeValue)
  }
}
