import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebarToggle", "darkModeToggle", "menuToggle"]
  static values = {
    sidebarOpen: { type: Boolean, default: false },
    darkMode: { type: Boolean, default: false },
    menuOpen: { type: Boolean, default: false }
  }

  connect() {
    // Carregar estado salvo do localStorage
    this.loadPersistedState()
    
    // Aplicar tema inicial
    this.applyDarkMode()
    
    // Fechar sidebar automaticamente em mobile ao trocar rota
    this.closeSidebarOnMobile()
  }

  disconnect() {
    // Salvar estado no localStorage
    this.savePersistedState()
  }

  // Sidebar Toggle
  toggleSidebar() {
    this.sidebarOpenValue = !this.sidebarOpenValue
    this.dispatchSidebarEvent()
  }

  closeSidebar() {
    this.sidebarOpenValue = false
    this.dispatchSidebarEvent()
  }

  // Dark Mode Toggle
  toggleDarkMode() {
    this.darkModeValue = !this.darkModeValue
    this.applyDarkMode()
  }

  // Menu Toggle (mobile)
  toggleMenu() {
    this.menuOpenValue = !this.menuOpenValue
  }

  // Aplicar dark mode ao HTML
  applyDarkMode() {
    document.documentElement.classList.toggle('dark', this.darkModeValue)
  }

  // Fechar sidebar em mobile ao trocar rota
  closeSidebarOnMobile() {
    if (window.innerWidth < 1280) {
      this.closeSidebar()
    }
  }

  // Disparar evento customizado para sincronizar com sidebar
  dispatchSidebarEvent() {
    const event = new CustomEvent('sidebar:toggle', {
      detail: { open: this.sidebarOpenValue },
      bubbles: true
    })
    this.element.dispatchEvent(event)
  }

  // Persistência no localStorage
  savePersistedState() {
    if (typeof localStorage !== 'undefined') {
      localStorage.setItem('header-sidebar-open', this.sidebarOpenValue)
      localStorage.setItem('header-dark-mode', this.darkModeValue)
    }
  }

  loadPersistedState() {
    if (typeof localStorage !== 'undefined') {
      const sidebarOpen = localStorage.getItem('header-sidebar-open')
      const darkMode = localStorage.getItem('header-dark-mode')
      
      if (sidebarOpen !== null) {
        this.sidebarOpenValue = sidebarOpen === 'true'
      }
      
      if (darkMode !== null) {
        this.darkModeValue = darkMode === 'true'
      }
    }
  }

  // Getters para usar no template
  get sidebarOpen() {
    return this.sidebarOpenValue
  }

  get darkMode() {
    return this.darkModeValue
  }

  get menuOpen() {
    return this.menuOpenValue
  }
}
