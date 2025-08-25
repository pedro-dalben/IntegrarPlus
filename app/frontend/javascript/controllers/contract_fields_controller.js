import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['companyField', 'cnpjField'];
  static values = {
    contractTypes: Array,
    currentType: String,
  };

  connect() {
    this.initializeContractFields();
  }

  contractTypeChanged() {
    this.loadContractFields();
  }

  initializeContractFields() {
    this.loadContractFields();
  }

  async loadContractFields() {
    const contractTypeId = this.contractTypeSelectTarget.value;

    if (!contractTypeId) {
      this.fieldsContainerTarget.innerHTML = '';
      return;
    }

    try {
      const response = await fetch(`/admin/contract_types/${contractTypeId}/fields`);
      const html = await response.text();
      this.fieldsContainerTarget.innerHTML = html;
    } catch (error) {
      this.fieldsContainerTarget.innerHTML =
        '<p class="text-red-500">Erro ao carregar campos do contrato</p>';
    }
  }

  setupContractTypeListener() {
    const contractTypeSelect = this.element
      .closest('form')
      .querySelector('select[name*="contract_type_id"]');
    if (contractTypeSelect) {
      contractTypeSelect.addEventListener('change', () => {
        this.currentTypeValue = contractTypeSelect.value;
        this.updateFields();
      });
    }
  }

  updateFields() {
    const currentType = this.contractTypesValue.find(
      ct => ct.id.toString() === this.currentTypeValue
    );

    if (currentType) {
      this.toggleField(this.companyFieldTarget, currentType.requires_company);
      this.toggleField(this.cnpjFieldTarget, currentType.requires_cnpj);
    } else {
      this.hideAllFields();
    }
  }

  toggleField(field, show) {
    if (show) {
      field.style.display = 'block';
      this.setFieldRequired(field, true);
    } else {
      field.style.display = 'none';
      this.setFieldRequired(field, false);
      this.clearFieldValue(field);
    }
  }

  setFieldRequired(field, required) {
    const input = field.querySelector('input');
    if (input) {
      if (required) {
        input.setAttribute('required', 'required');
      } else {
        input.removeAttribute('required');
      }
    }
  }

  clearFieldValue(field) {
    const input = field.querySelector('input');
    if (input) {
      input.value = '';
    }
  }

  hideAllFields() {
    if (this.hasCompanyFieldTarget) {
      this.toggleField(this.companyFieldTarget, false);
    }
    if (this.hasCnpjFieldTarget) {
      this.toggleField(this.cnpjFieldTarget, false);
    }
  }
}
