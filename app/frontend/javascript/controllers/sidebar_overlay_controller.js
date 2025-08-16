import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay"]

  connect() {
    console.log("Sidebar overlay controller connected")
    this.setupEventListeners()
  }

  disconnect() {
    this.removeEventListeners()
  }

  setupEventListeners() {
    this.sidebarToggleHandler = this.handleSidebarToggle.bind(this)
    document.addEventListener('sidebar-toggle', this.sidebarToggleHandler)
    
    this.clickHandler = this.handleClick.bind(this)
    this.element.addEventListener('click', this.clickHandler)
  }

  removeEventListeners() {
    document.removeEventListener('sidebar-toggle', this.sidebarToggleHandler)
    this.element.removeEventListener('click', this.clickHandler)
  }

  handleSidebarToggle(event) {
    const isCollapsed = event.detail?.collapsed || false
    
    if (window.innerWidth < 1280) {
      if (isCollapsed) {
        this.showOverlay()
      } else {
        this.hideOverlay()
      }
    }
  }

  handleClick(event) {
    if (window.innerWidth < 1280) {
      this.dispatch('sidebar-close')
    }
  }

  showOverlay() {
    this.overlayTarget.classList.remove('hidden')
    this.overlayTarget.classList.add('block')
  }

  hideOverlay() {
    this.overlayTarget.classList.add('hidden')
    this.overlayTarget.classList.remove('block')
  }
}
