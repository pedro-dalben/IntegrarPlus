import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["table"]

  filter(event) {
    const searchTerm = event.target.value.toLowerCase()
    const table = this.tableTarget || this.element.closest('table')
    const rows = table.querySelectorAll('tbody tr')

    rows.forEach(row => {
      const text = row.textContent.toLowerCase()
      if (text.includes(searchTerm)) {
        row.style.display = ''
      } else {
        row.style.display = 'none'
      }
    })
  }
}
