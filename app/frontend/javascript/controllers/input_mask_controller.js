import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static values = { type: String };

  connect() {
    this.element.addEventListener('input', this.applyMask.bind(this));
    this.element.addEventListener('keydown', this.handleKeydown.bind(this));
  }

  applyMask(event) {
    const input = event.target;
    const { value } = input;
    const cursorPosition = input.selectionStart;

    let maskedValue = '';
    let newCursorPosition = cursorPosition;

    switch (this.typeValue) {
      case 'cpf': {
        const result = this.maskCPF(value, cursorPosition);
        maskedValue = result.value;
        newCursorPosition = result.cursorPosition;
        break;
      }
      case 'cep': {
        const cepResult = this.maskCEP(value, cursorPosition);
        maskedValue = cepResult.value;
        newCursorPosition = cepResult.cursorPosition;
        break;
      }
      case 'telefone': {
        const telefoneResult = this.maskTelefone(value, cursorPosition);
        maskedValue = telefoneResult.value;
        newCursorPosition = telefoneResult.cursorPosition;
        break;
      }
      case 'crm': {
        maskedValue = this.maskCRM(value);
        newCursorPosition = Math.min(cursorPosition, maskedValue.length);
        break;
      }
      default:
        maskedValue = value;
    }

    if (maskedValue !== value) {
      input.value = maskedValue;
      // Usar setTimeout para garantir que o cursor seja posicionado corretamente
      setTimeout(() => {
        input.setSelectionRange(newCursorPosition, newCursorPosition);
      }, 0);
    }
  }

  handleKeydown(event) {
    // Permitir teclas de controle
    const allowedKeys = [
      'Backspace',
      'Delete',
      'Tab',
      'Escape',
      'Enter',
      'ArrowLeft',
      'ArrowRight',
      'ArrowUp',
      'ArrowDown',
    ];

    if (
      allowedKeys.includes(event.key) ||
      (event.key === 'a' && event.ctrlKey) || // Ctrl+A
      (event.key === 'c' && event.ctrlKey) || // Ctrl+C
      (event.key === 'v' && event.ctrlKey) || // Ctrl+V
      (event.key === 'x' && event.ctrlKey)
    ) {
      // Ctrl+X
      return;
    }

    // Para CPF, CEP e telefone, permitir apenas números
    if (
      (this.typeValue === 'cpf' || this.typeValue === 'cep' || this.typeValue === 'telefone') &&
      !/\d/.test(event.key)
    ) {
      event.preventDefault();
    }
  }

  maskCPF(value, cursorPosition) {
    // Remove tudo que não é dígito
    const numbers = value.replace(/\D/g, '');

    // Limita a 11 dígitos
    const limitedNumbers = numbers.substring(0, 11);

    let maskedValue = '';
    let newCursorPosition = cursorPosition;

    // Aplica a máscara
    if (limitedNumbers.length <= 3) {
      maskedValue = limitedNumbers;
    } else if (limitedNumbers.length <= 6) {
      maskedValue = limitedNumbers.replace(/(\d{3})(\d+)/, '$1.$2');
    } else if (limitedNumbers.length <= 9) {
      maskedValue = limitedNumbers.replace(/(\d{3})(\d{3})(\d+)/, '$1.$2.$3');
    } else {
      maskedValue = limitedNumbers.replace(/(\d{3})(\d{3})(\d{3})(\d+)/, '$1.$2.$3-$4');
    }

    // Ajustar posição do cursor considerando os caracteres adicionados
    const beforeCursor = value.substring(0, cursorPosition);
    const numbersBeforeCursor = beforeCursor.replace(/\D/g, '').length;

    if (numbersBeforeCursor <= 3) {
      newCursorPosition = numbersBeforeCursor;
    } else if (numbersBeforeCursor <= 6) {
      newCursorPosition = numbersBeforeCursor + 1; // +1 para o primeiro ponto
    } else if (numbersBeforeCursor <= 9) {
      newCursorPosition = numbersBeforeCursor + 2; // +2 para os dois pontos
    } else {
      newCursorPosition = numbersBeforeCursor + 3; // +3 para os dois pontos e hífen
    }

    return { value: maskedValue, cursorPosition: Math.min(newCursorPosition, maskedValue.length) };
  }

  maskCEP(value, cursorPosition) {
    // Remove tudo que não é dígito
    const numbers = value.replace(/\D/g, '');

    // Limita a 8 dígitos
    const limitedNumbers = numbers.substring(0, 8);

    let maskedValue = '';
    let newCursorPosition = cursorPosition;

    // Aplica a máscara
    if (limitedNumbers.length <= 5) {
      maskedValue = limitedNumbers;
    } else {
      maskedValue = limitedNumbers.replace(/(\d{5})(\d+)/, '$1-$2');
    }

    // Ajustar posição do cursor considerando o hífen adicionado
    const beforeCursor = value.substring(0, cursorPosition);
    const numbersBeforeCursor = beforeCursor.replace(/\D/g, '').length;

    if (numbersBeforeCursor <= 5) {
      newCursorPosition = numbersBeforeCursor;
    } else {
      newCursorPosition = numbersBeforeCursor + 1; // +1 para o hífen
    }

    return { value: maskedValue, cursorPosition: Math.min(newCursorPosition, maskedValue.length) };
  }

  maskTelefone(value, cursorPosition) {
    // Remove tudo que não é dígito
    const numbers = value.replace(/\D/g, '');

    // Limita a 11 dígitos
    const limitedNumbers = numbers.substring(0, 11);

    let maskedValue = '';
    let newCursorPosition = cursorPosition;

    // Aplica a máscara baseado no tamanho
    if (limitedNumbers.length <= 2) {
      maskedValue = limitedNumbers;
    } else if (limitedNumbers.length <= 6) {
      maskedValue = limitedNumbers.replace(/(\d{2})(\d+)/, '($1) $2');
    } else if (limitedNumbers.length <= 10) {
      maskedValue = limitedNumbers.replace(/(\d{2})(\d{4})(\d+)/, '($1) $2-$3');
    } else {
      maskedValue = limitedNumbers.replace(/(\d{2})(\d{5})(\d+)/, '($1) $2-$3');
    }

    // Ajustar posição do cursor considerando os caracteres adicionados
    const beforeCursor = value.substring(0, cursorPosition);
    const numbersBeforeCursor = beforeCursor.replace(/\D/g, '').length;

    if (numbersBeforeCursor <= 2) {
      newCursorPosition = numbersBeforeCursor === 0 ? 0 : numbersBeforeCursor === 1 ? 2 : 3; // ajuste para parêntese inicial
    } else if (numbersBeforeCursor <= 6) {
      newCursorPosition = numbersBeforeCursor + 3; // +3 para parênteses e espaço
    } else if (numbersBeforeCursor <= 10) {
      newCursorPosition = numbersBeforeCursor + 4; // +4 para parênteses, espaço e hífen
    } else {
      newCursorPosition = numbersBeforeCursor + 4; // +4 para parênteses, espaço e hífen
    }

    return { value: maskedValue, cursorPosition: Math.min(newCursorPosition, maskedValue.length) };
  }

  maskCRM(value) {
    // Remove caracteres especiais, mantém apenas números, letras e hífen
    const cleaned = value.replace(/[^\d\w-]/g, '').toUpperCase();

    // Limita o tamanho
    return cleaned.substring(0, 20);
  }
}
