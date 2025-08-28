import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.addEventListener("input", this.mask.bind(this))
  }

  mask(event) {
    let value = event.target.value.replace(/\D/g, "")

    if (value.length <= 11) {
      if (value.length <= 3) {
        value = value
      } else if (value.length <= 6) {
        value = value.replace(/(\d{3})(\d+)/, "$1.$2")
      } else if (value.length <= 9) {
        value = value.replace(/(\d{3})(\d{3})(\d+)/, "$1.$2.$3")
      } else {
        value = value.replace(/(\d{3})(\d{3})(\d{3})(\d+)/, "$1.$2.$3-$4")
      }
    }

    event.target.value = value
  }
}
