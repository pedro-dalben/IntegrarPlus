import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['input', 'hidden'];

  connect() {
    this.setupEventListeners();
    this.updateHiddenField();
  }

  setupEventListeners() {
    this.inputTarget.addEventListener('input', () => {
      this.validateAndFormat();
      this.updateHiddenField();
    });

    this.inputTarget.addEventListener('blur', () => {
      this.validateAndFormat();
      this.updateHiddenField();
    });
  }

  validateAndFormat() {
    let value = this.inputTarget.value.replace(/[^\d:]/g, '');

    if (!value) {
      this.inputTarget.value = '';
      return;
    }

    const parts = value.split(':');

    if (parts.length === 1) {
      const hours = parseInt(parts[0]) || 0;
      if (hours > 99) {
        hours = 99;
      }
      value = `${hours.toString().padStart(2, '0')}:00`;
    } else if (parts.length === 2) {
      let hours = parseInt(parts[0]) || 0;
      let minutes = parseInt(parts[1]) || 0;

      if (hours > 99) hours = 99;
      if (minutes > 59) minutes = 59;

      value = `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}`;
    }

    this.inputTarget.value = value;
  }

  updateHiddenField() {
    const value = this.inputTarget.value;
    if (!value) {
      this.hiddenTarget.value = '0';
      return;
    }

    const parts = value.split(':');
    if (parts.length === 2) {
      const hours = parseInt(parts[0]) || 0;
      const minutes = parseInt(parts[1]) || 0;
      const totalMinutes = (hours * 60) + minutes;
      this.hiddenTarget.value = totalMinutes.toString();
    } else {
      this.hiddenTarget.value = '0';
    }
  }

  getValue() {
    return this.inputTarget.value;
  }

  getMinutes() {
    return parseInt(this.hiddenTarget.value) || 0;
  }
}
