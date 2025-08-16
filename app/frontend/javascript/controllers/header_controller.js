import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "menu", "darkMode", "notifications", "userDropdown"]
  static values = { 
    darkMode: { type: Boolean, default: false },
    sidebarToggle: { type: Boolean, default: false },
    menuToggle: { type: Boolean, default: false },
    loaded: { type: Boolean, default: true }
  }

  connect() {
    
    // Carregar dark mode do localStorage
    this.darkModeValue = JSON.parse(localStorage.getItem('darkMode') || 'false')
  }

  disconnect() {
    // Salvar dark mode no localStorage
    localStorage.setItem('darkMode', JSON.stringify(this.darkModeValue))
  }

  // Sidebar toggle
  toggleSidebar() {
    this.sidebarToggleValue = !this.sidebarToggleValue
    console.log('Sidebar toggled:', this.sidebarToggleValue)
  }

  // Menu toggle
  toggleMenu() {
    this.menuToggleValue = !this.menuToggleValue
    console.log('Menu toggled:', this.menuToggleValue)
  }

  // Dark mode toggle
  toggleDarkMode() {
    this.darkModeValue = !this.darkModeValue
    console.log('Dark mode toggled:', this.darkModeValue)
  }

  // Notifications toggle
  toggleNotifications() {
    console.log('Notifications toggled')
  }

  // User dropdown toggle
  toggleUserDropdown() {
    console.log('User dropdown toggled')
  }

  // Computed properties
  get sidebarClasses() {
    return this.sidebarToggleValue ? 'xl:bg-transparent dark:xl:bg-transparent bg-gray-100 dark:bg-gray-800' : ''
  }

  get menuClasses() {
    return this.menuToggleValue ? 'bg-gray-100 dark:bg-gray-800' : ''
  }

  get bodyClasses() {
    return this.darkModeValue ? 'dark bg-gray-900' : ''
  }


}
