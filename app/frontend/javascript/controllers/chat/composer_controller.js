import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['input'];
  static values = { conversationIdentifier: String };

  connect() {
    if (this.hasInputTarget) {
      this.inputTarget.addEventListener('keydown', this.handleKeyDown.bind(this));
      this.inputTarget.addEventListener('input', this.autogrow.bind(this));
    }

    this.element.addEventListener('turbo:submit-end', this.handleSubmitEnd.bind(this));
  }

  disconnect() {
    if (this.hasInputTarget) {
      this.inputTarget.removeEventListener('keydown', this.handleKeyDown);
      this.inputTarget.removeEventListener('input', this.autogrow);
    }

    this.element.removeEventListener('turbo:submit-end', this.handleSubmitEnd);
  }

  handleSubmitEnd(event) {
    if (!this.hasInputTarget) return;

    const wasSuccessful = event.detail && event.detail.success !== false;

    if (wasSuccessful) {
      const savedValue = this.inputTarget.value.trim();

      if (savedValue.length > 0) {
        setTimeout(() => {
          if (this.inputTarget && this.inputTarget.value.trim() === savedValue) {
            this.inputTarget.value = '';
            this.inputTarget.style.height = 'auto';
            this.autogrow();
          }
        }, 2000);
      }
    }
  }

  handleKeyDown(event) {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault();
      event.stopPropagation();

      const content = this.inputTarget.value.trim();
      if (content) {
        if (this.submitting) {
          return;
        }

        this.submitting = true;

        this.element.requestSubmit();

        setTimeout(() => {
          this.submitting = false;
        }, 3000);
      }
    }
  }

  autogrow() {
    if (!this.hasInputTarget) return;

    const el = this.inputTarget;
    el.style.height = 'auto';
    el.style.height = `${el.scrollHeight}px`;
  }
}
