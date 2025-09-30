import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    console.log("Mobile menu controller connected");
  }

  toggle() {
    console.log("Toggle called");
    if (this.hasMenuTarget) {
      this.menuTarget.classList.toggle("hidden");
      console.log("Menu classes after toggle:", this.menuTarget.className);
    } else {
      console.log("Menu target not found");
    }
  }

  close() {
    if (this.hasMenuTarget) {
      this.menuTarget.classList.add("hidden");
    }
  }
}
