import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "form"]
  static values = { url: String }

  connect() {
    this.debouncedSearch = this.debounce(this.performSearch.bind(this), 500)
    this.isSearching = false
  }

  search() {
    if (this.inputTarget.value.trim().length > 0) {
      this.debouncedSearch()
    } else {
      this.clearSearch()
    }
  }

  async performSearch() {
    const query = this.inputTarget.value.trim()

    if (query.length === 0) {
      this.clearSearch()
      return
    }

    this.isSearching = true
    this.showLoading()

    try {
      const url = new URL(this.urlValue, window.location.origin)
      url.searchParams.set('query', query)
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
      this.showError()
    } finally {
      this.isSearching = false
      this.hideLoading()
    }
  }

  clearSearch() {
    this.inputTarget.value = ''

    // Remove os parâmetros da URL
    const url = new URL(window.location)
    url.searchParams.delete('query')
    url.searchParams.delete('page')
    window.history.pushState({}, '', url)

    // Recarrega a página para mostrar todos os resultados
    window.location.reload()
  }

  async loadInitialResults() {
    try {
      const response = await fetch(this.urlValue, {
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
      console.error('Erro ao carregar resultados:', error)
    }
  }

  updateResults(html) {
    // Atualiza a URL sem recarregar a página
    const url = new URL(window.location)
    const query = this.inputTarget.value.trim()

    if (query.length > 0) {
      url.searchParams.set('query', query)
      url.searchParams.set('page', '1')
    } else {
      url.searchParams.delete('query')
      url.searchParams.delete('page')
    }

    // Atualiza a URL sem recarregar
    window.history.pushState({}, '', url)

    // Atualiza o conteúdo da página
    const parser = new DOMParser()
    const doc = parser.parseFromString(html, 'text/html')

    // Atualiza apenas a seção de resultados (tabela e paginação)
    const currentTable = document.querySelector('.bg-white.dark\\:bg-gray-800.shadow-md.rounded-lg.overflow-hidden, .bg-white.dark\\:bg-gray-800.rounded-lg.shadow.border.border-gray-200.dark\\:border-gray-700.overflow-hidden')
    const newTable = doc.querySelector('.bg-white.dark\\:bg-gray-800.shadow-md.rounded-lg.overflow-hidden, .bg-white.dark\\:bg-gray-800.rounded-lg.shadow.border.border-gray-200.dark\\:border-gray-700.overflow-hidden')

    if (currentTable && newTable) {
      currentTable.replaceWith(newTable)
    }

    // Atualiza a paginação se existir
    const currentPagination = document.querySelector('[aria-label="Pagination"]')
    const newPagination = doc.querySelector('[aria-label="Pagination"]')

    if (currentPagination && newPagination) {
      currentPagination.closest('.bg-white.dark\\:bg-gray-800.px-4.py-3').replaceWith(newPagination.closest('.bg-white.dark\\:bg-gray-800.px-4.py-3'))
    } else if (newPagination) {
      // Se não há paginação atual mas há nova, adiciona
      const tableContainer = document.querySelector('.bg-white.dark\\:bg-gray-800.shadow-md.rounded-lg.overflow-hidden, .bg-white.dark\\:bg-gray-800.rounded-lg.shadow.border.border-gray-200.dark\\:border-gray-700.overflow-hidden')
      if (tableContainer) {
        tableContainer.parentNode.appendChild(newPagination.closest('.bg-white.dark\\:bg-gray-800.px-4.py-3'))
      }
    }

    // Atualiza o valor do input para manter a busca
    this.inputTarget.value = query
  }

  showLoading() {
    // Adicionar indicador de carregamento se necessário
    const loadingIndicator = document.createElement('div')
    loadingIndicator.id = 'search-loading'
    loadingIndicator.className = 'absolute inset-0 bg-white bg-opacity-75 flex items-center justify-center z-10'
    loadingIndicator.innerHTML = '<div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>'

    if (this.hasResultsTarget) {
      this.resultsTarget.style.position = 'relative'
      this.resultsTarget.appendChild(loadingIndicator)
    }
  }

  hideLoading() {
    const loadingIndicator = document.getElementById('search-loading')
    if (loadingIndicator) {
      loadingIndicator.remove()
    }
  }

  showError() {
    console.error('Erro na busca. Tente novamente.')
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
