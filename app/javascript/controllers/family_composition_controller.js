import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tbody", "template", "row"]

  addRow() {
    const template = this.templateTarget.content.cloneNode(true)
    this.tbodyTarget.appendChild(template)
  }

  removeRow(event) {
    const row = event.target.closest("tr")
    if (row && this.rowTargets.length > 0) {
      row.remove()
    }
  }
}

