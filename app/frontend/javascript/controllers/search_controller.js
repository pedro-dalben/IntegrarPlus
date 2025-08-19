import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "row", "results"]
  static values = { 
    url: String,
    debounce: { type: Number, default: 300 }
  }

  connect() {
    this.debounceTimeout = null
    this.search = this.search.bind(this)
  }

  search() {
    if (this.debounceTimeout) {
      clearTimeout(this.debounceTimeout)
    }

    this.debounceTimeout = setTimeout(() => {
      this.performSearch()
    }, this.debounceValue)
  }

  performSearch() {
    const query = this.inputTarget.value.trim().toLowerCase()
    
    if (query.length === 0) {
      this.showAllResults()
      return
    }

    // Busca local nas linhas da tabela
    if (this.hasRowTarget) {
      this.rowTargets.forEach(row => {
        const text = row.textContent.toLowerCase()
        const shouldShow = text.includes(query)
        row.style.display = shouldShow ? '' : 'none'
      })
    }
  }

  showAllResults() {
    if (this.hasRowTarget) {
      this.rowTargets.forEach(row => {
        row.style.display = ''
      })
    }
  }

  // Método para busca via AJAX (futuro)
  async performAjaxSearch() {
    const query = this.inputTarget.value.trim()
    
    if (query.length === 0) {
      this.showAllResults()
      return
    }

    try {
      const response = await fetch(`${this.urlValue}?query=${encodeURIComponent(query)}`, {
        headers: {
          'Accept': 'text/html',
          'X-Requested-With': 'XMLHttpRequest'
        }
      })

      if (response.ok) {
        const html = await response.text()
        this.updateResults(html)
      }
    } catch (error) {
      console.error('Erro na busca:', error)
    }
  }

  updateResults(html) {
    if (this.hasResultsTarget) {
      this.resultsTarget.innerHTML = html
    } else {
      // Fallback para atualizar a página inteira
      window.location.href = `${this.urlValue}?query=${encodeURIComponent(this.inputTarget.value)}`
    }
  }
}
