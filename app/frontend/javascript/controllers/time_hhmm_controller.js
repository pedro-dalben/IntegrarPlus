import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['input', 'hidden'];

  connect() {
    this.setupEventListeners();
    this.updateHiddenField();
  }

  setupEventListeners() {
    this.inputTarget.addEventListener('input', (event) => {
      this.validateAndFormat(event);
      this.updateHiddenField();
    });

    this.inputTarget.addEventListener('blur', () => {
      this.finalizeFormat();
      this.updateHiddenField();
    });

    this.inputTarget.addEventListener('keydown', (event) => {
      this.handleKeydown(event);
    });
  }

  handleKeydown(event) {
    const allowedKeys = ['Backspace', 'Delete', 'Tab', 'Escape', 'Enter', 'ArrowLeft', 'ArrowRight', 'ArrowUp', 'ArrowDown'];
    const allowedChars = /[\d:]/;
    
    if (allowedKeys.includes(event.key)) {
      return;
    }
    
    if (!allowedChars.test(event.key)) {
      event.preventDefault();
      return;
    }
  }

  validateAndFormat(event) {
    let value = this.inputTarget.value.replace(/[^\d:]/g, '');
    const cursorPosition = this.inputTarget.selectionStart;
    
    if (!value) {
      this.inputTarget.value = '';
      return;
    }

    const parts = value.split(':');
    let newValue = '';

    if (parts.length === 1) {
      let hours = parseInt(parts[0]) || 0;
      if (hours > 99) {
        hours = 99;
      }
      newValue = `${hours.toString().padStart(2, '0')}:00`;
    } else if (parts.length === 2) {
      let hours = parseInt(parts[0]) || 0;
      let minutes = parseInt(parts[1]) || 0;

      if (hours > 99) hours = 99;
      if (minutes > 59) minutes = 59;

      newValue = `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}`;
    }

    if (newValue !== this.inputTarget.value) {
      this.inputTarget.value = newValue;
      this.adjustCursorPosition(cursorPosition, value, newValue);
    }
  }

  adjustCursorPosition(oldPosition, oldValue, newValue) {
    let newPosition = oldPosition;
    
    if (oldValue.length < newValue.length) {
      if (oldPosition === 2 && oldValue.length === 2) {
        newPosition = 3;
      } else if (oldPosition === 5 && oldValue.length === 5) {
        newPosition = 6;
      }
    } else if (oldValue.length > newValue.length) {
      if (oldPosition === 3 && oldValue.length === 3) {
        newPosition = 2;
      }
    }
    
    this.inputTarget.setSelectionRange(newPosition, newPosition);
  }

  finalizeFormat() {
    let value = this.inputTarget.value.replace(/[^\d:]/g, '');
    
    if (!value) {
      this.inputTarget.value = '';
      return;
    }

    const parts = value.split(':');

    if (parts.length === 1) {
      let hours = parseInt(parts[0]) || 0;
      if (hours > 99) {
        hours = 99;
      }
      this.inputTarget.value = `${hours.toString().padStart(2, '0')}:00`;
    } else if (parts.length === 2) {
      let hours = parseInt(parts[0]) || 0;
      let minutes = parseInt(parts[1]) || 0;

      if (hours > 99) hours = 99;
      if (minutes > 59) minutes = 59;

      this.inputTarget.value = `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}`;
    }
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
