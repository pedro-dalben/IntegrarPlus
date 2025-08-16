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
    console.log("Header: toggleSidebar() chamado")
    this.dispatch("sidebar-toggle")
    console.log("Header: evento sidebar-toggle disparado")
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
    console.log("Header: handleSidebarToggle() chamado", event)
    setTimeout(() => this.updatePosition(), 300)
  }

  updatePosition() {
    console.log("Header: updatePosition() chamado")
    const sidebar = document.querySelector('.sidebar')
    if (sidebar) {
      const isCollapsed = sidebar.classList.contains('sidebar-collapsed')
      console.log("Header: sidebar encontrada, collapsed:", isCollapsed)
      const sidebarWidth = isCollapsed ? 90 : this.sidebarWidthValue
      
      this.element.style.left = '0'
      this.element.style.right = '0'
      
      const hamburgerButton = this.element.querySelector('.hamburger-button')
      if (hamburgerButton && window.innerWidth >= 1280) {
        const marginLeft = isCollapsed ? '90px' : `${this.sidebarWidthValue}px`
        hamburgerButton.style.marginLeft = marginLeft
        console.log("Header: margem do botão ajustada para:", marginLeft)
      } else if (hamburgerButton) {
        hamburgerButton.style.marginLeft = '0'
        console.log("Header: margem do botão resetada para 0")
      }
    } else {
      console.log("Header: sidebar não encontrada")
    }
  }
}
