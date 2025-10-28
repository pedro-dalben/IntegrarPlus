import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['spinner', 'content'];
  static values = {
    delay: { type: Number, default: 200 },
  };

  connect() {
    this.boundShowLoading = this.showLoading.bind(this);
    this.boundHideLoading = this.hideLoading.bind(this);

    document.addEventListener('turbo:before-fetch-request', this.boundShowLoading);
    document.addEventListener('turbo:before-fetch-response', this.boundHideLoading);
    document.addEventListener('turbo:submit-start', this.boundShowLoading);
    document.addEventListener('turbo:submit-end', this.boundHideLoading);
  }

  disconnect() {
    document.removeEventListener('turbo:before-fetch-request', this.boundShowLoading);
    document.removeEventListener('turbo:before-fetch-response', this.boundHideLoading);
    document.removeEventListener('turbo:submit-start', this.boundShowLoading);
    document.removeEventListener('turbo:submit-end', this.boundHideLoading);

    if (this.timeout) clearTimeout(this.timeout);
  }

  showLoading() {
    this.timeout = setTimeout(() => {
      if (this.hasSpinnerTarget) {
        this.spinnerTarget.classList.remove('hidden');
        this.spinnerTarget.classList.add('flex');
      }

      if (this.hasContentTarget) {
        this.contentTarget.classList.add('opacity-50', 'pointer-events-none');
      }

      document.body.classList.add('loading');
    }, this.delayValue);
  }

  hideLoading() {
    if (this.timeout) {
      clearTimeout(this.timeout);
      this.timeout = null;
    }

    if (this.hasSpinnerTarget) {
      this.spinnerTarget.classList.add('hidden');
      this.spinnerTarget.classList.remove('flex');
    }

    if (this.hasContentTarget) {
      this.contentTarget.classList.remove('opacity-50', 'pointer-events-none');
    }

    document.body.classList.remove('loading');
  }
}
