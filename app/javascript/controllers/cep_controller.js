import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['zipCode', 'street', 'neighborhood', 'city', 'state', 'loading'];
  static values = { url: String };

  connect() {
    this.urlValue = this.urlValue || '/cep';
  }

  search() {
    const zipCode = this.zipCodeTarget.value.replace(/\D/g, '');

    if (zipCode.length !== 8) {
      this.clearFields();
      return;
    }

    this.showLoading(true);
    this.disableFields(true);

    fetch(`${this.urlValue}/${zipCode}`)
      .then(response => response.json())
      .then(data => {
        if (data.error) {
          this.showError(data.error);
          this.clearFields();
        } else {
          this.fillFields(data);
        }
      })
      .catch(error => {
        this.showError('Erro ao consultar CEP');
        this.clearFields();
      })
      .finally(() => {
        this.showLoading(false);
        this.disableFields(false);
      });
  }

  formatZipCode() {
    let value = this.zipCodeTarget.value.replace(/\D/g, '');

    if (value.length > 8) {
      value = value.substring(0, 8);
    }

    if (value.length > 5) {
      value = value.replace(/(\d{5})(\d{1,3})/, '$1-$2');
    }

    this.zipCodeTarget.value = value;
  }

  fillFields(data) {
    if (this.hasStreetTarget) this.streetTarget.value = data.street || '';
    if (this.hasNeighborhoodTarget) this.neighborhoodTarget.value = data.neighborhood || '';
    if (this.hasCityTarget) this.cityTarget.value = data.city || '';
    if (this.hasStateTarget) this.stateTarget.value = data.state || '';

    this.dispatch('filled', {
      detail: {
        address: data,
        coordinates: data.coordinates,
      },
    });
  }

  clearFields() {
    if (this.hasStreetTarget) this.streetTarget.value = '';
    if (this.hasNeighborhoodTarget) this.neighborhoodTarget.value = '';
    if (this.hasCityTarget) this.cityTarget.value = '';
    if (this.hasStateTarget) this.stateTarget.value = '';
  }

  showLoading(show) {
    if (this.hasLoadingTarget) {
      this.loadingTarget.style.display = show ? 'block' : 'none';
    }
  }

  disableFields(disable) {
    const fields = [
      this.streetTarget,
      this.neighborhoodTarget,
      this.cityTarget,
      this.stateTarget,
    ].filter(field => field);

    fields.forEach(field => {
      field.disabled = disable;
    });
  }

  showError(message) {
    let errorElement = this.element.querySelector('.zip-error');

    if (!errorElement) {
      errorElement = document.createElement('div');
      errorElement.className = 'zip-error text-sm text-red-600 mt-1';
      this.zipCodeTarget.parentNode.appendChild(errorElement);
    }

    errorElement.textContent = message;

    setTimeout(() => {
      if (errorElement.parentNode) {
        errorElement.parentNode.removeChild(errorElement);
      }
    }, 5000);
  }

  buscar() {
    this.search();
  }
  formatarCep() {
    this.formatZipCode();
  }
  preencherCampos(data) {
    this.fillFields(data);
  }
  limparCampos() {
    this.clearFields();
  }
  mostrarLoading(show) {
    this.showLoading(show);
  }
  desabilitarCampos(disable) {
    this.disableFields(disable);
  }
  mostrarErro(message) {
    this.showError(message);
  }
}
