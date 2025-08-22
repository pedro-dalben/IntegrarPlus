import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results"]
  static values = { url: String }

  connect() {
    this.debouncedSearch = this.debounce(this.performSearch.bind(this), 300)
  }

  search() {
    this.debouncedSearch()
  }

  async performSearch() {
    const query = this.inputTarget.value.trim()
    
    if (query.length === 0) {
      this.loadInitialResults()
      return
    }

    try {
      const response = await fetch(`${this.urlValue}?query=${encodeURIComponent(query)}`, {
        headers: {
          'X-Requested-With': 'XMLHttpRequest'
        }
      })

      if (response.ok) {
        const html = await response.text()
        this.resultsTarget.innerHTML = html
      }
    } catch (error) {
      console.error('Erro na busca:', error)
    }
  }

  async loadInitialResults() {
    try {
      const response = await fetch(this.urlValue, {
        headers: {
          'X-Requested-With': 'XMLHttpRequest'
        }
      })

      if (response.ok) {
        const html = await response.text()
        this.resultsTarget.innerHTML = html
      }
    } catch (error) {
      console.error('Erro ao carregar resultados:', error)
    }
  }

  debounce(func, wait) {
    let timeout
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout)
        func(...args)
      }
      clearTimeout(timeout)
      timeout = setTimeout(later, wait)
    }
  }
}
