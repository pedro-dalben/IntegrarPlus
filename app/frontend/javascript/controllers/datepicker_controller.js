import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

export default class extends Controller {
  static values = { enableTime: Boolean, dateFormat: String }

  connect() {
    this.picker = flatpickr(this.element, {
      enableTime: this.enableTimeValue || false,
      dateFormat: this.dateFormatValue || (this.enableTimeValue ? 'd/m/Y H:i' : 'd/m/Y')
    })
  }

  disconnect() {
    this.picker?.destroy()
  }
}


