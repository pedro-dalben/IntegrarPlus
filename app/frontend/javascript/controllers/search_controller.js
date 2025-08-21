import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "row", "results"]
  static values = { 
    url: String,
    debounce: { type: Number, default: 500 }
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
      this.performAjaxSearch()
    }, this.debounceValue)
  }

  clear() {
    this.inputTarget.value = ''
    this.performAjaxSearch()
  }

  async performAjaxSearch() {
    const query = this.inputTarget.value.trim()
    
    try {
      const url = new URL(this.urlValue, window.location.origin)
      if (query.length > 0) {
        url.searchParams.set('query', query)
      }
      url.searchParams.set('page', '1')

      const response = await fetch(url.toString(), {
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
      this.performLocalSearch()
    }
  }

  performLocalSearch() {
    const query = this.inputTarget.value.trim().toLowerCase()
    
    if (query.length === 0) {
      this.showAllResults()
      return
    }

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

  updateResults(html) {
    const resultsTarget = this.element.querySelector('[data-search-target="results"]')
    if (resultsTarget) {
      resultsTarget.innerHTML = html
    } else {
      window.location.href = `${this.urlValue}?query=${encodeURIComponent(this.inputTarget.value)}`
    }
  }
}
