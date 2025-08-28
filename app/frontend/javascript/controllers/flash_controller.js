import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  connect() {
    this.autoHide();
  }

  autoHide() {
    setTimeout(() => {
      this.element.remove();
    }, 5000);
  }

  close() {
    this.element.remove();
  }
}
