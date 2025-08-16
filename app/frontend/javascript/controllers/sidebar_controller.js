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
    this.removeEventListeners()
  }

  setupEventListeners() {
    this.resizeHandler = this.handleResize.bind(this)
    window.addEventListener('resize', this.resizeHandler)
    
    this.clickOutsideHandler = this.handleClickOutside.bind(this)
    document.addEventListener('click', this.clickOutsideHandler)
    
    this.escapeHandler = this.handleEscape.bind(this)
    document.addEventListener('keydown', this.escapeHandler)
    
    this.sidebarCloseHandler = this.handleSidebarClose.bind(this)
    document.addEventListener('sidebar-close', this.sidebarCloseHandler)
    
    this.sidebarToggleHandler = this.handleSidebarToggle.bind(this)
    document.addEventListener('sidebar-toggle', this.sidebarToggleHandler)
  }

  removeEventListeners() {
    window.removeEventListener('resize', this.resizeHandler)
    document.removeEventListener('click', this.clickOutsideHandler)
    document.removeEventListener('keydown', this.escapeHandler)
    document.removeEventListener('sidebar-close', this.sidebarCloseHandler)
    document.removeEventListener('sidebar-toggle', this.sidebarToggleHandler)
  }

  initializeState() {
    this.collapsedValue = localStorage.getItem('sidebarCollapsed') === 'true'
    this.selectedValue = localStorage.getItem('sidebarSelected') || ''
    this.updateSidebarClasses()
  }

  toggle() {
    this.collapsedValue = !this.collapsedValue
    localStorage.setItem('sidebarCollapsed', this.collapsedValue.toString())
    this.updateSidebarClasses()
    this.dispatch('sidebar-toggle', { detail: { collapsed: this.collapsedValue } })
  }

  handleSidebarToggle(event) {
    if (window.innerWidth < 1280) {
      this.toggle()
    } else {
      this.toggle()
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
    if (this.collapsedValue) {
      this.element.classList.add('sidebar-collapsed')
      this.element.classList.remove('sidebar-expanded')
    } else {
      this.element.classList.add('sidebar-expanded')
      this.element.classList.remove('sidebar-collapsed')
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
    if (window.innerWidth >= 1280) {
      this.element.classList.remove('-translate-x-full')
    } else {
      if (!this.collapsedValue) {
        this.element.classList.add('-translate-x-full')
      }
    }
  }

  handleClickOutside(event) {
    if (window.innerWidth < 1280 && !this.element.contains(event.target)) {
      this.closeMobile()
    }
  }

  handleEscape(event) {
    if (event.key === 'Escape') {
      this.closeMobile()
    }
  }

  handleSidebarClose() {
    this.closeMobile()
  }

  closeMobile() {
    if (window.innerWidth < 1280) {
      this.element.classList.add('-translate-x-full')
    }
  }

  openMobile() {
    if (window.innerWidth < 1280) {
      this.element.classList.remove('-translate-x-full')
    }
  }
}


