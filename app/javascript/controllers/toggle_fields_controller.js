import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["trigger", "content"]

  connect() {
    this.update()
  }

  update() {
    const trigger = this.triggerTargets.find(t => t.checked)

    if (trigger) {
      const showContent = trigger.value === "true"
      this.contentTargets.forEach(content => {
        content.style.display = showContent ? "" : "none"
      })
    }
  }
}

