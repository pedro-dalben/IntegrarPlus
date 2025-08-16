import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Content area controller connected")
    this.updateMargin()
  }

  updateMargin() {
    const sidebar = document.querySelector('.sidebar')
    if (sidebar) {
      const isCollapsed = sidebar.classList.contains('xl:w-[90px]')
      const marginLeft = isCollapsed ? '90px' : '190px'
      this.element.style.marginLeft = `calc(100vw - ${marginLeft})`
    }
  }
}
