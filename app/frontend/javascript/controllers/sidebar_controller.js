import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menuItem", "submenu"]
  static values = {
    selected: { type: String, default: 'Dashboard' }
  }

  connect() {
    // Carregar estado salvo do localStorage
    this.loadPersistedState()
    
    // Escutar eventos do header
    this.listenToHeaderEvents()
    
    // Fechar sidebar em mobile ao clicar fora
    this.setupClickOutside()
  }

  disconnect() {
    // Salvar estado no localStorage
    this.savePersistedState()
  }

  // Escutar eventos do header
  listenToHeaderEvents() {
    document.addEventListener('sidebar:toggle', (event) => {
      this.handleSidebarToggle(event.detail.open)
    })
  }

  // Manipular toggle da sidebar
  handleSidebarToggle(open) {
    if (open) {
      this.openSidebar()
    } else {
      this.closeSidebar()
    }
  }

  // Abrir sidebar
  openSidebar() {
    this.element.classList.remove('-translate-x-full')
    this.element.classList.add('translate-x-0', 'xl:w-[90px]')
  }

  // Fechar sidebar
  closeSidebar() {
    this.element.classList.add('-translate-x-full')
    this.element.classList.remove('translate-x-0', 'xl:w-[90px]')
  }

  // Toggle de item do menu
  toggleMenuItem(event) {
    const menuItem = event.currentTarget
    const menuName = menuItem.getAttribute('data-menu-name')
    
    if (this.selectedValue === menuName) {
      this.selectedValue = ''
    } else {
      this.selectedValue = menuName
    }
  }

  // Setup para fechar sidebar ao clicar fora (mobile)
  setupClickOutside() {
    document.addEventListener('click', (event) => {
      if (window.innerWidth < 1280 && !this.element.contains(event.target)) {
        this.closeSidebar()
      }
    })
  }

  // Verificar se sidebar está aberta
  get isOpen() {
    return this.element.classList.contains('translate-x-0')
  }

  // Verificar se sidebar está colapsada (modo estreito)
  get isCollapsed() {
    return this.element.classList.contains('xl:w-[90px]')
  }

  // Persistência no localStorage
  savePersistedState() {
    if (typeof localStorage !== 'undefined') {
      localStorage.setItem('sidebar-selected', this.selectedValue)
    }
  }

  loadPersistedState() {
    if (typeof localStorage !== 'undefined') {
      const selected = localStorage.getItem('sidebar-selected')
      if (selected !== null) {
        this.selectedValue = selected
      }
    }
  }

  // Getters para usar no template
  get selected() {
    return this.selectedValue
  }
}
