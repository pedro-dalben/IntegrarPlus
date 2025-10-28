import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['panel', 'arrow'];

  connect() {
    document.addEventListener('click', this.outside.bind(this));
  }

  disconnect() {
    document.removeEventListener('click', this.outside.bind(this));
  }

  toggle() {
    if (this.panelTarget.classList.contains('hidden')) {
      this.open();
    } else {
      this.close();
    }
  }

  open() {
    this.panelTarget.classList.remove('hidden');
    if (this.hasArrowTarget) {
      this.arrowTarget.style.transform = 'rotate(180deg)';
    }
  }

  close() {
    this.panelTarget.classList.add('hidden');
    if (this.hasArrowTarget) {
      this.arrowTarget.style.transform = 'rotate(0deg)';
    }
  }

  outside(event) {
    if (!this.element.contains(event.target)) {
      this.close();
    }
  }
}
