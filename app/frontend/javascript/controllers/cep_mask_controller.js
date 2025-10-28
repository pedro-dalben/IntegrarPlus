import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  connect() {
    this.element.addEventListener('input', this.mask.bind(this));
  }

  mask(event) {
    let value = event.target.value.replace(/\D/g, '');

    if (value.length <= 8) {
      if (value.length <= 5) {
        value = value;
      } else {
        value = value.replace(/(\d{5})(\d+)/, '$1-$2');
      }
    }

    event.target.value = value;
  }
}
