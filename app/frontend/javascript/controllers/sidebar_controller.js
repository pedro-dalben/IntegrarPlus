console.log("Sidebar controller file loaded")

// app/frontend/javascript/controllers/sidebar_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menuItem", "dropdown", "overlay"]
  static values = { 
    collapsed: { type: Boolean, default: false },
    selected: { type: String, default: "" }
  }

  connect() {
    console.log("Sidebar controller connected")
    this.setupEventListeners()
    this.initializeState()
  }

  disconnect() {
    console.log("Sidebar controller disconnected")
    this.removeEventListeners()
  }

  setupEventListeners() {
    console.log("Sidebar: setupEventListeners()")
    this.resizeHandler = this.handleResize.bind(this)
    window.addEventListener('resize', this.resizeHandler)
    
    this.escapeHandler = this.handleEscape.bind(this)
    document.addEventListener('keydown', this.escapeHandler)
    
    this.sidebarCloseHandler = this.handleSidebarClose.bind(this)
    document.addEventListener('sidebar-close', this.sidebarCloseHandler)
    
    this.sidebarToggleHandler = this.handleSidebarToggle.bind(this)
    document.addEventListener('sidebar-toggle', this.sidebarToggleHandler)
    console.log("Sidebar: event listeners configurados")
  }

  removeEventListeners() {
    window.removeEventListener('resize', this.resizeHandler)
    document.removeEventListener('keydown', this.escapeHandler)
    document.removeEventListener('sidebar-close', this.sidebarCloseHandler)
    document.removeEventListener('sidebar-toggle', this.sidebarToggleHandler)
  }

  initializeState() {
    console.log("Sidebar: initializeState()")
    this.collapsedValue = localStorage.getItem('sidebarCollapsed') === 'true'
    this.selectedValue = localStorage.getItem('sidebarSelected') || ''
    console.log("Sidebar: estado inicial - collapsed:", this.collapsedValue, "selected:", this.selectedValue)
    this.updateSidebarClasses()
  }

  toggle() {
    console.log("Sidebar: toggle() chamado, estado atual:", this.collapsedValue)
    this.collapsedValue = !this.collapsedValue
    localStorage.setItem('sidebarCollapsed', this.collapsedValue.toString())
    console.log("Sidebar: novo estado - collapsed:", this.collapsedValue)
    this.updateSidebarClasses()
    this.dispatch('sidebar-toggle', { detail: { collapsed: this.collapsedValue } })
    console.log("Sidebar: evento sidebar-toggle disparado com detail:", { collapsed: this.collapsedValue })
  }

  handleSidebarToggle(event) {
    console.log("Sidebar: handleSidebarToggle() chamado", event)
    console.log("Sidebar: window.innerWidth:", window.innerWidth)
    
    if (window.innerWidth < 1280) {
      console.log("Sidebar: modo mobile - alternando visibilidade")
      this.toggleMobile()
    } else {
      console.log("Sidebar: modo desktop - alternando colapso")
      this.toggle()
    }
  }

  toggleMobile() {
    console.log("Sidebar: toggleMobile() chamado")
    const isHidden = this.element.classList.contains('-translate-x-full')
    console.log("Sidebar: mobile - está oculta:", isHidden)
    
    if (isHidden) {
      this.element.classList.remove('-translate-x-full')
      this.element.classList.add('mobile-open')
      console.log("Sidebar: mobile - sidebar aberta")
    } else {
      this.element.classList.add('-translate-x-full')
      this.element.classList.remove('mobile-open')
      console.log("Sidebar: mobile - sidebar fechada")
    }
  }

  toggleDropdown(event) {
    const menuItem = event.currentTarget
    const menuName = menuItem.dataset.menu
    
    if (this.selectedValue === menuName) {
      this.selectedValue = ''
    } else {
      this.selectedValue = menuName
    }
    
    localStorage.setItem('sidebarSelected', this.selectedValue)
    this.updateDropdownStates()
  }

  selectMenuItem(event) {
    const menuItem = event.currentTarget
    const menuName = menuItem.dataset.menu
    
    this.selectedValue = menuName
    localStorage.setItem('sidebarSelected', this.selectedValue)
    this.updateDropdownStates()
  }

  updateSidebarClasses() {
    console.log("Sidebar: updateSidebarClasses() - collapsed:", this.collapsedValue)
    if (this.collapsedValue) {
      this.element.classList.add('sidebar-collapsed')
      this.element.classList.remove('sidebar-expanded')
      console.log("Sidebar: classes atualizadas - collapsed adicionada")
    } else {
      this.element.classList.add('sidebar-expanded')
      this.element.classList.remove('sidebar-collapsed')
      console.log("Sidebar: classes atualizadas - expanded adicionada")
    }
  }

  updateDropdownStates() {
    this.menuItemTargets.forEach(item => {
      const menuName = item.dataset.menu
      const dropdown = this.element.querySelector(`[data-dropdown="${menuName}"]`)
      
      if (this.selectedValue === menuName) {
        item.classList.add('menu-item-active')
        if (dropdown) {
          dropdown.classList.remove('hidden')
          dropdown.classList.add('block')
        }
      } else {
        item.classList.remove('menu-item-active')
        if (dropdown) {
          dropdown.classList.add('hidden')
          dropdown.classList.remove('block')
        }
      }
    })
  }

  handleResize() {
    console.log("Sidebar: handleResize() - window.innerWidth:", window.innerWidth)
    if (window.innerWidth >= 1280) {
      this.element.classList.remove('-translate-x-full', 'mobile-open')
      console.log("Sidebar: desktop - removidas classes mobile")
    } else {
      if (!this.collapsedValue) {
        this.element.classList.add('-translate-x-full')
        this.element.classList.remove('mobile-open')
        console.log("Sidebar: mobile - adicionada classe -translate-x-full")
      }
    }
  }

  handleEscape(event) {
    if (event.key === 'Escape') {
      this.closeMobile()
    }
  }

  handleSidebarClose() {
    console.log("Sidebar: handleSidebarClose() chamado")
    this.closeMobile()
  }

  closeMobile() {
    console.log("Sidebar: closeMobile() chamado")
    if (window.innerWidth < 1280) {
      this.element.classList.add('-translate-x-full')
      this.element.classList.remove('mobile-open')
      console.log("Sidebar: mobile - sidebar fechada")
    }
  }

  openMobile() {
    console.log("Sidebar: openMobile() chamado")
    if (window.innerWidth < 1280) {
      this.element.classList.remove('-translate-x-full')
      this.element.classList.add('mobile-open')
      console.log("Sidebar: mobile - sidebar aberta")
    }
  }
}


