import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static values = {
    isProduction: Boolean,
  };

  connect() {
    if (!this.isProductionValue) return;

    this.disableAutofill();
  }

  disableAutofill() {
    const passwordFields = this.element.querySelectorAll('input[type="password"]');

    passwordFields.forEach(field => {
      if (field.dataset.disableAutofill === 'true') {
        field.setAttribute('autocomplete', 'new-password');
        field.setAttribute('data-lpignore', 'true');
        field.setAttribute('data-form-type', 'other');

        this.addFakeFields(field);
        this.observeField(field);
      }
    });
  }

  addFakeFields(passwordField) {
    const form = passwordField.closest('form');
    if (!form) return;

    const fakeUsername = document.createElement('input');
    fakeUsername.type = 'text';
    fakeUsername.name = 'fake_username';
    fakeUsername.style.display = 'none';
    fakeUsername.setAttribute('autocomplete', 'username');
    fakeUsername.setAttribute('tabindex', '-1');

    const fakePassword = document.createElement('input');
    fakePassword.type = 'password';
    fakePassword.name = 'fake_password';
    fakePassword.style.display = 'none';
    fakePassword.setAttribute('autocomplete', 'current-password');
    fakePassword.setAttribute('tabindex', '-1');

    form.insertBefore(fakeUsername, form.firstChild);
    form.insertBefore(fakePassword, form.firstChild);

    this.fakeFields = { fakeUsername, fakePassword };
  }

  observeField(field) {
    const observer = new MutationObserver(() => {
      if (field.value && field.value !== this.lastValue) {
        this.lastValue = field.value;
        this.clearFakeFields();
      }
    });

    observer.observe(field, {
      attributes: true,
      attributeFilter: ['value'],
    });

    field.addEventListener('input', () => {
      this.clearFakeFields();
    });

    field.addEventListener('focus', () => {
      this.clearFakeFields();
    });
  }

  clearFakeFields() {
    if (this.fakeFields) {
      this.fakeFields.fakeUsername.value = '';
      this.fakeFields.fakePassword.value = '';
    }
  }
}
