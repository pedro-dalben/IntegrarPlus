import { Controller } from '@hotwired/stimulus';
import IMask from 'imask';

export default class extends Controller {
  static targets = ['input'];
  static values = {
    type: String,
    options: Object
  };

  connect() {
    this.initializeMask();
  }

  disconnect() {
    if (this.mask) {
      this.mask.destroy();
    }
  }

  initializeMask() {
    const input = this.inputTarget;
    const type = this.typeValue;
    const options = this.optionsValue || {};

    let maskOptions = {};

    switch (type) {
      case 'cpf':
        maskOptions = {
          mask: '000.000.000-00',
          lazy: false
        };
        break;

      case 'cnpj':
        maskOptions = {
          mask: '00.000.000/0000-00',
          lazy: false
        };
        break;

      case 'phone':
        maskOptions = {
          mask: [
            { mask: '(00) 0000-0000' },
            { mask: '(00) 00000-0000' }
          ],
          lazy: false
        };
        break;

      case 'date':
        maskOptions = {
          mask: 'DD/MM/YYYY',
          lazy: false,
          blocks: {
            'DD': { mask: IMask.MaskedRange, from: 1, to: 31 },
            'MM': { mask: IMask.MaskedRange, from: 1, to: 12 },
            'YYYY': { mask: IMask.MaskedRange, from: 1900, to: 9999 }
          }
        };
        break;

      case 'email':
        // Para email, não aplicamos máscara, apenas validação nativa do HTML5
        return;

      case 'custom':
        maskOptions = options;
        break;

      default:
        console.warn(`Tipo de máscara não reconhecido: ${type}`);
        return;
    }

    this.mask = IMask(input, maskOptions);

    this.mask.on('accept', () => {
      this.dispatch('masked', { detail: { value: this.mask.value } });
    });
  }

  getValue() {
    return this.mask ? this.mask.value : '';
  }

  getUnmaskedValue() {
    return this.mask ? this.mask.unmaskedValue : '';
  }
}
