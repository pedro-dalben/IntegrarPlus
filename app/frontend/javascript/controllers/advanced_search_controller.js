import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['input', 'results', 'form', 'loading', 'error', 'suggestions']
  static values = {
    url: String,
    debounceMs: { type: Number, default: 300 },
    minLength: { type: Number, default: 2 }
  }

  connect() {
    this.debouncedSearch = this.debounce(this.performSearch.bind(this), this.debounceMsValue)
    this.isSearching = false
    this.currentRequest = null
  }

  disconnect() {
    if (this.currentRequest) {
      this.currentRequest.abort()
    }
  }

  search() {
    const query = this.inputTarget.value.trim()

    if (query.length === 0) {
      this.clearSearch()
      return
    }

    if (query.length < this.minLengthValue) {
      this.showSuggestions()
      return
    }

    this.debouncedSearch()
  }

  async performSearch() {
    const query = this.inputTarget.value.trim()

    if (query.length === 0 || query.length < this.minLengthValue) {
      this.clearSearch()
      return
    }

    this.isSearching = true
    this.showLoading()
    this.hideError()
    this.hideSuggestions()

    try {
      if (this.currentRequest) {
        this.currentRequest.abort()
      }

      const url = new URL(this.urlValue, window.location.origin)
      url.searchParams.set('query', query)
      url.searchParams.set('page', '1')

      const controller = new AbortController()
      this.currentRequest = controller

      const response = await fetch(url.toString(), {
        headers: {
          Accept: 'text/html',
          'X-Requested-With': 'XMLHttpRequest',
        },
        signal: controller.signal
      })

      if (response.ok) {
        const html = await response.text()
        this.updateResults(html)
        this.hideError()
      } else {
        throw new Error(`HTTP ${response.status}`)
      }
    } catch (error) {
      if (error.name === 'AbortError') {
        return
      }
      this.showError()
      console.error('Erro na busca:', error)
    } finally {
      this.isSearching = false
      this.hideLoading()
      this.currentRequest = null
    }
  }

  clearSearch() {
    this.inputTarget.value = ''
    this.hideResults()
    this.hideLoading()
    this.hideError()
    this.hideSuggestions()
  }

  showLoading() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.remove('hidden')
    }
  }

  hideLoading() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.add('hidden')
    }
  }

  showError() {
    if (this.hasErrorTarget) {
      this.errorTarget.classList.remove('hidden')
    }
  }

  hideError() {
    if (this.hasErrorTarget) {
      this.errorTarget.classList.add('hidden')
    }
  }

  showSuggestions() {
    if (this.hasSuggestionsTarget) {
      this.suggestionsTarget.classList.remove('hidden')
    }
  }

  hideSuggestions() {
    if (this.hasSuggestionsTarget) {
      this.suggestionsTarget.classList.add('hidden')
    }
  }

  updateResults(html) {
    if (this.hasResultsTarget) {
      this.resultsTarget.innerHTML = html
      this.resultsTarget.classList.remove('hidden')
    } else {
      window.location.reload()
    }
  }

  hideResults() {
    if (this.hasResultsTarget) {
      this.resultsTarget.classList.add('hidden')
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

  // Métodos para sugestões de busca
  showSearchTips() {
    const tips = [
      'Use aspas para busca exata: "relatório técnico"',
      'Busque por tipo: tipo:relatorio',
      'Busque por autor: autor:"João Silva"',
      'Busque por categoria: categoria:tecnica',
      'Use * para busca parcial: relator*'
    ]

    if (this.hasSuggestionsTarget) {
      this.suggestionsTarget.innerHTML = `
        <div class="p-4 bg-blue-50 border border-blue-200 rounded-lg">
          <h4 class="font-medium text-blue-900 mb-2">Dicas de busca:</h4>
          <ul class="text-sm text-blue-700 space-y-1">
            ${tips.map(tip => `<li>• ${tip}</li>`).join('')}
          </ul>
        </div>
      `
      this.showSuggestions()
    }
  }

  // Método para busca avançada
  advancedSearch(event) {
    event.preventDefault()
    this.performSearch()
  }
}
