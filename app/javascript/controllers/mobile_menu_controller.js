import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['menu'];

  connect() {}

  toggle() {
    if (this.hasMenuTarget) {
      this.menuTarget.classList.toggle('hidden');
    } else {
    }
  }

  close() {
    if (this.hasMenuTarget) {
      this.menuTarget.classList.add('hidden');
    }
  }
}
