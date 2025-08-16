import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { 
    darkMode: { type: Boolean, default: false },
    sidebarWidth: { type: Number, default: 290 }
  }

  connect() {
    console.log("Header component controller connected")
    this.initializeDarkMode()
    this.setupEventListeners()
    this.updatePosition()
  }

  disconnect() {
    this.saveDarkMode()
    this.removeEventListeners()
  }

  setupEventListeners() {
    this.resizeHandler = this.updatePosition.bind(this)
    window.addEventListener('resize', this.resizeHandler)
    
    this.sidebarToggleHandler = this.handleSidebarToggle.bind(this)
    document.addEventListener('sidebar-toggle', this.sidebarToggleHandler)
  }

  removeEventListeners() {
    window.removeEventListener('resize', this.resizeHandler)
    document.removeEventListener('sidebar-toggle', this.sidebarToggleHandler)
  }

  initializeDarkMode() {
    this.darkModeValue = JSON.parse(localStorage.getItem('darkMode') || 'false')
    this.applyDarkMode()
  }

  saveDarkMode() {
    localStorage.setItem('darkMode', JSON.stringify(this.darkModeValue))
  }

  toggleSidebar() {
    this.dispatch("sidebar-toggle")
    setTimeout(() => this.updatePosition(), 300)
  }

  toggleDarkMode() {
    this.darkModeValue = !this.darkModeValue
    this.applyDarkMode()
    this.saveDarkMode()
    console.log('Dark mode toggled:', this.darkModeValue)
  }

  applyDarkMode() {
    if (this.darkModeValue) {
      document.documentElement.classList.add('dark')
    } else {
      document.documentElement.classList.remove('dark')
    }
  }

  handleSidebarToggle(event) {
    setTimeout(() => this.updatePosition(), 300)
  }

  updatePosition() {
    const sidebar = document.querySelector('.sidebar')
    if (sidebar) {
      const isCollapsed = sidebar.classList.contains('sidebar-collapsed')
      const sidebarWidth = isCollapsed ? 90 : this.sidebarWidthValue
      
      this.element.style.left = '0'
      this.element.style.right = '0'
      
      const hamburgerButton = this.element.querySelector('.hamburger-button')
      if (hamburgerButton && window.innerWidth >= 1280) {
        const marginLeft = isCollapsed ? '90px' : `${this.sidebarWidthValue}px`
        hamburgerButton.style.marginLeft = marginLeft
      } else if (hamburgerButton) {
        hamburgerButton.style.marginLeft = '0'
      }
    }
  }
}
