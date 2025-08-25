import { Controller } from '@hotwired/stimulus';
import TomSelect from 'tom-select';

export default class extends Controller {
  static targets = ['select'];
  static values = { options: Object };

  connect() {
    this.tomSelect = new TomSelect(this.selectTarget, {
      plugins: ['remove_button'],
      render: {
        option(data, escape) {
          return `<div class="option-item">${escape(data.text)}</div>`;
        },
        item(data, escape) {
          return `<div class="item-tag">${escape(data.text)}</div>`;
        },
      },
      ...this.optionsValue,
    });
  }

  disconnect() {
    if (this.tomSelect) {
      this.tomSelect.destroy();
    }
  }
}
