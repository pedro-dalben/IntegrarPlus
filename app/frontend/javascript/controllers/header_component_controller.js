import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { 
    darkMode: { type: Boolean, default: false },
    sidebarWidth: { type: Number, default: 290 }
  }

  connect() {
    console.log("Header component controller connected")
    this.darkModeValue = JSON.parse(localStorage.getItem('darkMode') || 'false')
    this.updatePosition()
  }

  disconnect() {
    localStorage.setItem('darkMode', JSON.stringify(this.darkModeValue))
  }

  toggleSidebar() {
    this.dispatch("sidebar-toggle")
    setTimeout(() => this.updatePosition(), 300)
  }

  toggleDarkMode() {
    this.darkModeValue = !this.darkModeValue
    console.log('Dark mode toggled:', this.darkModeValue)
  }

  updatePosition() {
    const sidebar = document.querySelector('.sidebar')
    if (sidebar) {
      const isCollapsed = sidebar.classList.contains('xl:w-[90px]')
      const leftPosition = isCollapsed ? '90px' : `${this.sidebarWidthValue}px`
      this.element.style.left = `calc(100vw - ${leftPosition})`
    }
  }
}
