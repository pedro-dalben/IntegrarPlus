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
    
    // Listener para redimensionamento da janela
    this.resizeHandler = this.updatePosition.bind(this)
    window.addEventListener('resize', this.resizeHandler)
  }

  disconnect() {
    localStorage.setItem('darkMode', JSON.stringify(this.darkModeValue))
    if (this.resizeHandler) {
      window.removeEventListener('resize', this.resizeHandler)
    }
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
      
      // Em mobile, header ocupa toda largura
      if (window.innerWidth < 1280) {
        this.element.style.left = '0'
        this.element.style.right = '0'
      } else {
        // Em desktop, header respeita sidebar
        this.element.style.left = leftPosition
        this.element.style.right = '0'
      }
    }
  }
}
