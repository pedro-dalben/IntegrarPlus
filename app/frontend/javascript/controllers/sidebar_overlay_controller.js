import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay"]

  connect() {
    console.log("Sidebar overlay controller connected")
    this.setupEventListeners()
  }

  disconnect() {
    console.log("Sidebar overlay controller disconnected")
    this.removeEventListeners()
  }

  setupEventListeners() {
    console.log("Sidebar overlay: setupEventListeners()")
    this.sidebarToggleHandler = this.handleSidebarToggle.bind(this)
    document.addEventListener('sidebar-toggle', this.sidebarToggleHandler)
    
    this.clickHandler = this.handleClick.bind(this)
    this.element.addEventListener('click', this.clickHandler)
    console.log("Sidebar overlay: event listeners configurados")
  }

  removeEventListeners() {
    document.removeEventListener('sidebar-toggle', this.sidebarToggleHandler)
    this.element.removeEventListener('click', this.clickHandler)
  }

  handleSidebarToggle(event) {
    console.log("Sidebar overlay: handleSidebarToggle() chamado", event)
    const isCollapsed = event.detail?.collapsed || false
    console.log("Sidebar overlay: isCollapsed:", isCollapsed, "window.innerWidth:", window.innerWidth)
    
    if (window.innerWidth < 1280) {
      if (isCollapsed) {
        console.log("Sidebar overlay: mostrando overlay")
        this.showOverlay()
      } else {
        console.log("Sidebar overlay: ocultando overlay")
        this.hideOverlay()
      }
    } else {
      console.log("Sidebar overlay: desktop - ignorando overlay")
    }
  }

  handleClick(event) {
    console.log("Sidebar overlay: handleClick() chamado")
    if (window.innerWidth < 1280) {
      console.log("Sidebar overlay: disparando evento sidebar-close")
      this.dispatch('sidebar-close')
    }
  }

  showOverlay() {
    console.log("Sidebar overlay: showOverlay()")
    this.overlayTarget.classList.remove('hidden')
    this.overlayTarget.classList.add('block')
  }

  hideOverlay() {
    console.log("Sidebar overlay: hideOverlay()")
    this.overlayTarget.classList.add('hidden')
    this.overlayTarget.classList.remove('block')
  }
}
