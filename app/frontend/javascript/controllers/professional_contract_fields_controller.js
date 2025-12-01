import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = [
    'pjFields',
    'autonomoFields',
    'fechadoFields',
    'porHoraFields'
  ];

  connect() {
    setTimeout(() => {
      this.updateContractTypeFields();
      this.updatePaymentFields();
    }, 100);
  }

  contractTypeChanged(event) {
    this.updateContractTypeFields();
  }

  paymentTypeChanged(event) {
    this.updatePaymentFields();
  }

  updateContractTypeFields() {
    const contractTypeSelect = this.element.querySelector('[name*="[contract_type_enum]"]');
    if (!contractTypeSelect) return;

    const contractType = contractTypeSelect.value;

    if (contractType === 'pj') {
      if (this.hasPjFieldsTarget) {
        this.pjFieldsTarget.style.display = 'block';
        this.pjFieldsTarget.setAttribute('aria-hidden', 'false');
      }
      if (this.hasAutonomoFieldsTarget) {
        this.autonomoFieldsTarget.style.display = 'none';
        this.autonomoFieldsTarget.setAttribute('aria-hidden', 'true');
        this.clearFieldValue(this.autonomoFieldsTarget);
      }
    } else if (contractType === 'autonomo') {
      if (this.hasAutonomoFieldsTarget) {
        this.autonomoFieldsTarget.style.display = 'block';
        this.autonomoFieldsTarget.setAttribute('aria-hidden', 'false');
      }
      if (this.hasPjFieldsTarget) {
        this.pjFieldsTarget.style.display = 'none';
        this.pjFieldsTarget.setAttribute('aria-hidden', 'true');
        this.clearFieldValue(this.pjFieldsTarget);
      }
    } else {
      if (this.hasPjFieldsTarget) {
        this.pjFieldsTarget.style.display = 'none';
        this.pjFieldsTarget.setAttribute('aria-hidden', 'true');
        this.clearFieldValue(this.pjFieldsTarget);
      }
      if (this.hasAutonomoFieldsTarget) {
        this.autonomoFieldsTarget.style.display = 'none';
        this.autonomoFieldsTarget.setAttribute('aria-hidden', 'true');
        this.clearFieldValue(this.autonomoFieldsTarget);
      }
    }
  }

  updatePaymentFields() {
    const paymentTypeSelect = this.element.querySelector('[name*="[payment_type]"]');
    if (!paymentTypeSelect) return;

    const paymentType = paymentTypeSelect.value;

    if (paymentType === 'fechado') {
      if (this.hasFechadoFieldsTarget) {
        this.fechadoFieldsTarget.style.display = 'block';
        this.fechadoFieldsTarget.setAttribute('aria-hidden', 'false');
      }
      if (this.hasPorHoraFieldsTarget) {
        this.porHoraFieldsTarget.style.display = 'none';
        this.porHoraFieldsTarget.setAttribute('aria-hidden', 'true');
        this.clearFieldValue(this.porHoraFieldsTarget);
      }
    } else if (paymentType === 'por_hora') {
      if (this.hasPorHoraFieldsTarget) {
        this.porHoraFieldsTarget.style.display = 'block';
        this.porHoraFieldsTarget.setAttribute('aria-hidden', 'false');
      }
      if (this.hasFechadoFieldsTarget) {
        this.fechadoFieldsTarget.style.display = 'none';
        this.fechadoFieldsTarget.setAttribute('aria-hidden', 'true');
        this.clearFieldValue(this.fechadoFieldsTarget);
      }
    } else {
      if (this.hasFechadoFieldsTarget) {
        this.fechadoFieldsTarget.style.display = 'none';
        this.fechadoFieldsTarget.setAttribute('aria-hidden', 'true');
        this.clearFieldValue(this.fechadoFieldsTarget);
      }
      if (this.hasPorHoraFieldsTarget) {
        this.porHoraFieldsTarget.style.display = 'none';
        this.porHoraFieldsTarget.setAttribute('aria-hidden', 'true');
        this.clearFieldValue(this.porHoraFieldsTarget);
      }
    }
  }

  setFieldRequired(field, required) {
    const input = field.querySelector('input, textarea, select');
    if (input) {
      if (required) {
        input.setAttribute('required', 'required');
      } else {
        input.removeAttribute('required');
      }
    }
  }

  clearFieldValue(field) {
    const inputs = field.querySelectorAll('input, textarea, select');
    inputs.forEach(input => {
      if (input.type !== 'hidden') {
        input.value = '';
      }
    });
  }
}

