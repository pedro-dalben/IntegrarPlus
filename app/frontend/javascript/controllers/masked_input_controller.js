import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { 
    type: String,
    placeholder: String 
  }

  connect() {
    this.input = this.element
    this.applyMask()
    // Aplicar máscara no valor inicial se existir
    if (this.input.value) {
      this.handleInput({ target: this.input })
    }
  }

  applyMask() {
    this.input.addEventListener('input', this.handleInput.bind(this))
    this.input.addEventListener('keydown', this.handleKeydown.bind(this))
    this.input.addEventListener('blur', this.handleBlur.bind(this))
  }

  handleInput(event) {
    const input = event.target
    const value = input.value.replace(/\D/g, '') // Remove caracteres não numéricos
    
    let maskedValue = ''
    
    switch (this.typeValue) {
      case 'cpf':
        maskedValue = this.maskCPF(value)
        break
      case 'cnpj':
        maskedValue = this.maskCNPJ(value)
        break
      case 'phone':
        maskedValue = this.maskPhone(value)
        break
      case 'cep':
        maskedValue = this.maskCEP(value)
        break
      case 'date':
        maskedValue = this.maskDate(value)
        break
      case 'time':
        maskedValue = this.maskTime(value)
        break
      default:
        maskedValue = value
    }
    
    input.value = maskedValue
    this.validateInput(input)
  }

  handleKeydown(event) {
    // Permitir teclas de navegação
    const allowedKeys = ['Backspace', 'Delete', 'Tab', 'Escape', 'Enter', 'ArrowLeft', 'ArrowRight', 'ArrowUp', 'ArrowDown']
    if (allowedKeys.includes(event.key)) {
      return
    }
    
    // Para campos de data, permitir apenas números
    if (this.typeValue === 'date' && !/\d/.test(event.key)) {
      event.preventDefault()
    }
  }

  handleBlur(event) {
    // Validar quando o campo perde o foco
    this.validateInput(event.target)
  }

  maskCPF(value) {
    return value
      .replace(/\D/g, '')
      .replace(/(\d{3})(\d)/, '$1.$2')
      .replace(/(\d{3})(\d)/, '$1.$2')
      .replace(/(\d{3})(\d{1,2})/, '$1-$2')
      .slice(0, 14)
  }

  maskCNPJ(value) {
    return value
      .replace(/\D/g, '')
      .replace(/(\d{2})(\d)/, '$1.$2')
      .replace(/(\d{3})(\d)/, '$1.$2')
      .replace(/(\d{3})(\d)/, '$1/$2')
      .replace(/(\d{4})(\d{1,2})/, '$1-$2')
      .slice(0, 18)
  }

  maskPhone(value) {
    const cleaned = value.replace(/\D/g, '')
    
    if (cleaned.length <= 10) {
      return cleaned
        .replace(/(\d{2})(\d)/, '($1) $2')
        .replace(/(\d{4})(\d)/, '$1-$2')
        .slice(0, 14)
    } else {
      return cleaned
        .replace(/(\d{2})(\d)/, '($1) $2')
        .replace(/(\d{5})(\d)/, '$1-$2')
        .slice(0, 15)
    }
  }

  maskCEP(value) {
    return value
      .replace(/\D/g, '')
      .replace(/(\d{5})(\d)/, '$1-$2')
      .slice(0, 9)
  }

  maskDate(value) {
    return value
      .replace(/\D/g, '')
      .replace(/(\d{2})(\d)/, '$1/$2')
      .replace(/(\d{2})\/(\d{2})(\d)/, '$1/$2/$3')
      .slice(0, 10)
  }

  maskTime(value) {
    return value
      .replace(/\D/g, '')
      .replace(/(\d{2})(\d)/, '$1:$2')
      .slice(0, 5)
  }

  validateInput(input) {
    const value = input.value
    let isValid = false
    
    // Para CPF, só validar se tiver 11 dígitos
    if (this.typeValue === 'cpf') {
      const digits = value.replace(/\D/g, '')
      if (digits.length === 11) {
        isValid = this.validateCPF(value)
      } else if (digits.length > 0) {
        // Mostrar como inválido se tiver dígitos mas não 11
        isValid = false
      } else {
        // Não mostrar erro se estiver vazio
        this.clearValidationState(input)
        return
      }
    } else {
      switch (this.typeValue) {
        case 'cnpj':
          isValid = this.validateCNPJ(value)
          break
        case 'phone':
          isValid = this.validatePhone(value)
          break
        case 'cep':
          isValid = this.validateCEP(value)
          break
        case 'date':
          isValid = this.validateDate(value)
          break
        case 'time':
          isValid = this.validateTime(value)
          break
        default:
          isValid = true
      }
    }
    
    this.updateValidationState(input, isValid)
  }

  validateCPF(cpf) {
    cpf = cpf.replace(/\D/g, '')
    
    // Verificar se tem 11 dígitos
    if (cpf.length !== 11) return false
    
    // Verificar se não são todos os dígitos iguais
    if (/^(\d)\1+$/.test(cpf)) return false
    
    // Calcular primeiro dígito verificador
    let sum = 0
    for (let i = 0; i < 9; i++) {
      sum += parseInt(cpf.charAt(i)) * (10 - i)
    }
    let remainder = (sum * 10) % 11
    if (remainder === 10 || remainder === 11) remainder = 0
    if (remainder !== parseInt(cpf.charAt(9))) return false
    
    // Calcular segundo dígito verificador
    sum = 0
    for (let i = 0; i < 10; i++) {
      sum += parseInt(cpf.charAt(i)) * (11 - i)
    }
    remainder = (sum * 10) % 11
    if (remainder === 10 || remainder === 11) remainder = 0
    if (remainder !== parseInt(cpf.charAt(10))) return false
    
    return true
  }

  validateCNPJ(cnpj) {
    cnpj = cnpj.replace(/\D/g, '')
    
    if (cnpj.length !== 14) return false
    if (/^(\d)\1+$/.test(cnpj)) return false
    
    let sum = 0
    let weight = 2
    
    for (let i = 11; i >= 0; i--) {
      sum += parseInt(cnpj.charAt(i)) * weight
      weight = weight === 9 ? 2 : weight + 1
    }
    
    let remainder = sum % 11
    let digit1 = remainder < 2 ? 0 : 11 - remainder
    
    if (digit1 !== parseInt(cnpj.charAt(12))) return false
    
    sum = 0
    weight = 2
    
    for (let i = 12; i >= 0; i--) {
      sum += parseInt(cnpj.charAt(i)) * weight
      weight = weight === 9 ? 2 : weight + 1
    }
    
    remainder = sum % 11
    let digit2 = remainder < 2 ? 0 : 11 - remainder
    
    return digit2 === parseInt(cnpj.charAt(13))
  }

  validatePhone(phone) {
    const cleaned = phone.replace(/\D/g, '')
    return cleaned.length >= 10 && cleaned.length <= 11
  }

  validateCEP(cep) {
    const cleaned = cep.replace(/\D/g, '')
    return cleaned.length === 8
  }

  validateDate(date) {
    const cleaned = date.replace(/\D/g, '')
    if (cleaned.length !== 8) return false
    
    const day = parseInt(cleaned.substring(0, 2))
    const month = parseInt(cleaned.substring(2, 4))
    const year = parseInt(cleaned.substring(4, 8))
    
    if (day < 1 || day > 31) return false
    if (month < 1 || month > 12) return false
    if (year < 1900 || year > 2100) return false
    
    const dateObj = new Date(year, month - 1, day)
    return dateObj.getDate() === day && 
           dateObj.getMonth() === month - 1 && 
           dateObj.getFullYear() === year
  }

  validateTime(time) {
    const cleaned = time.replace(/\D/g, '')
    if (cleaned.length !== 4) return false
    
    const hours = parseInt(cleaned.substring(0, 2))
    const minutes = parseInt(cleaned.substring(2, 4))
    
    return hours >= 0 && hours <= 23 && minutes >= 0 && minutes <= 59
  }

  updateValidationState(input, isValid) {
    const container = input.closest('.field-container') || input.parentElement
    
    if (isValid) {
      input.classList.remove('border-red-500', 'focus:border-red-500', 'focus:ring-red-500')
      input.classList.add('border-green-500', 'focus:border-green-500', 'focus:ring-green-500')
      
      // Remover mensagem de erro se existir
      const errorMessage = container.querySelector('.error-message')
      if (errorMessage) {
        errorMessage.remove()
      }
    } else {
      input.classList.remove('border-green-500', 'focus:border-green-500', 'focus:ring-green-500')
      input.classList.add('border-red-500', 'focus:border-red-500', 'focus:ring-red-500')
      
      // Adicionar mensagem de erro se não existir
      if (!container.querySelector('.error-message')) {
        const errorMessage = document.createElement('p')
        errorMessage.className = 'error-message text-red-500 text-xs mt-1'
        errorMessage.textContent = this.getErrorMessage()
        container.appendChild(errorMessage)
      }
    }
  }

  clearValidationState(input) {
    const container = input.closest('.field-container') || input.parentElement
    
    input.classList.remove('border-red-500', 'focus:border-red-500', 'focus:ring-red-500', 'border-green-500', 'focus:border-green-500', 'focus:ring-green-500')
    input.classList.add('border-gray-300', 'focus:border-blue-500', 'focus:ring-blue-500')
    
    // Remover mensagem de erro se existir
    const errorMessage = container.querySelector('.error-message')
    if (errorMessage) {
      errorMessage.remove()
    }
  }

  getErrorMessage() {
    switch (this.typeValue) {
      case 'cpf':
        return 'CPF inválido'
      case 'cnpj':
        return 'CNPJ inválido'
      case 'phone':
        return 'Telefone inválido'
      case 'cep':
        return 'CEP inválido'
      case 'date':
        return 'Data inválida'
      case 'time':
        return 'Horário inválido'
      default:
        return 'Valor inválido'
    }
  }
}
