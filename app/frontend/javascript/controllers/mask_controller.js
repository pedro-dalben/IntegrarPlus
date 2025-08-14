import { Controller } from "@hotwired/stimulus"
import * as IMask from "imask"

export default class extends Controller {
  static targets = ["input"]
  static values = { 
    type: String,
    options: Object 
  }

  connect() {
    this.initializeMask()
  }

  disconnect() {
    if (this.mask) {
      this.mask.destroy()
    }
  }

  initializeMask() {
    const input = this.inputTarget
    const type = this.typeValue || 'default'
    const options = this.optionsValue || {}

    let maskOptions = {}

    switch (type) {
      case 'cpf':
        maskOptions = {
          mask: '000.000.000-00',
          lazy: false,
          placeholderChar: '_'
        }
        break
      
      case 'cnpj':
        maskOptions = {
          mask: '00.000.000/0000-00',
          lazy: false,
          placeholderChar: '_'
        }
        break
      
      case 'phone':
        maskOptions = {
          mask: [
            { mask: '(00) 00000-0000' },
            { mask: '(00) 0000-0000' }
          ],
          lazy: false,
          placeholderChar: '_'
        }
        break
      
      case 'custom':
        maskOptions = options
        break
      
      default:
        return
    }

    this.mask = IMask.IMask(input, maskOptions)
    
    this.mask.on('accept', () => {
      this.dispatch('masked', { detail: { value: this.mask.value } })
    })
  }

  getValue() {
    return this.mask ? this.mask.value : this.inputTarget.value
  }

  getUnmaskedValue() {
    return this.mask ? this.mask.unmaskedValue : this.inputTarget.value
  }
}
