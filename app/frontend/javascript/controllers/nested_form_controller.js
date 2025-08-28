import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template"]
  static values = { index: Number }

  connect() {
    this.indexValue = this.containerTarget.children.length
  }

  add(event) {
    event.preventDefault()

    const template = this.templateTarget.innerHTML
    const newForm = template.replace(/NEW_RECORD/g, new Date().getTime())

    this.containerTarget.insertAdjacentHTML("beforeend", newForm)
    this.indexValue++
  }

  remove(event) {
    event.preventDefault()

    const item = event.target.closest("[data-nested-form-item]")
    const destroyInput = item.querySelector("input[name*='_destroy']")

    if (destroyInput) {
      destroyInput.value = "1"
      item.style.display = "none"
    } else {
      item.remove()
    }
  }
}
