import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
  static targets = ["select"]

  connect() {
    this.initializeTomSelect()
  }

  disconnect() {
    if (this.tomSelect) {
      this.tomSelect.destroy()
    }
  }

  initializeTomSelect() {
    this.selectTargets.forEach(select => {
      const options = {
        plugins: ['remove_button'],
        placeholder: select.dataset.placeholder || 'Selecione...',
        allowEmptyOption: true,
        closeAfterSelect: false,
        maxItems: select.multiple ? null : 1,
        searchField: ['text'],
        valueField: 'value',
        labelField: 'text',
        create: false,
        onInitialize: () => {
          select.classList.add('tom-select-initialized')
        }
      }

      this.tomSelect = new TomSelect(select, options)
    })
  }

  getTomSelectInstance() {
    return this.tomSelect
  }
}
