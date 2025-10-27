import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "selectedSchool"]
  static values = {
    url: String,
    minLength: { type: Number, default: 3 },
    debounceMs: { type: Number, default: 300 }
  }

  connect() {
    this.debounceTimer = null
    this.selectedSchoolData = null
    document.addEventListener('click', this.handleClickOutside.bind(this))
  }

  disconnect() {
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer)
    }
    document.removeEventListener('click', this.handleClickOutside.bind(this))
  }

  search() {
    const query = this.inputTarget.value.trim()

    if (query.length < this.minLengthValue) {
      this.hideResults()
      return
    }

    // Debounce para evitar muitas requisições
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer)
    }

    this.debounceTimer = setTimeout(() => {
      this.performSearch(query)
    }, this.debounceMsValue)
  }

  async performSearch(query) {
    try {
      this.showLoading()

      const response = await fetch(`${this.urlValue}?q=${encodeURIComponent(query)}`, {
        method: 'GET',
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        }
      })

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      const data = await response.json()
      this.displayResults(data.schools || [])

    } catch (error) {
      console.error('Erro ao buscar escolas:', error)
      this.showError('Erro ao buscar escolas. Tente novamente.')
    }
  }

  displayResults(schools) {
    if (schools.length === 0) {
      this.resultsTarget.innerHTML = `
        <div class="p-3 text-sm text-gray-500 text-center">
          Nenhuma escola encontrada
        </div>
      `
      this.showResults()
      return
    }

    const resultsHtml = schools.map(school => `
      <div class="school-result p-3 hover:bg-gray-50 dark:hover:bg-gray-800 cursor-pointer border-b border-gray-200 dark:border-gray-700 last:border-b-0"
           data-school-id="${school.id}"
           data-school-name="${school.name}"
           data-school-code="${school.code}"
           data-school-address="${school.address}"
           data-school-city="${school.city}"
           data-school-state="${school.state}"
           data-school-type="${school.type}"
           data-action="click->school-search#selectSchool">
        <div class="font-medium text-gray-900 dark:text-gray-100">${school.name}</div>
        <div class="text-sm text-gray-600 dark:text-gray-400">${school.address}</div>
        <div class="text-xs text-gray-500 dark:text-gray-500">${school.city} - ${school.state} • ${school.type}</div>
      </div>
    `).join('')

    this.resultsTarget.innerHTML = resultsHtml
    this.showResults()
  }

  selectSchool(event) {
    const element = event.currentTarget
    const schoolData = {
      id: element.dataset.schoolId,
      name: element.dataset.schoolName,
      code: element.dataset.schoolCode,
      address: element.dataset.schoolAddress,
      city: element.dataset.schoolCity,
      state: element.dataset.schoolState,
      type: element.dataset.schoolType
    }

    this.selectedSchoolData = schoolData
    this.inputTarget.value = schoolData.name
    this.hideResults()
    this.updateSelectedSchoolDisplay(schoolData)
  }

  updateSelectedSchoolDisplay(schoolData) {
    if (this.hasSelectedSchoolTarget) {
      this.selectedSchoolTarget.innerHTML = `
        <div class="p-3 bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-lg">
          <div class="flex items-start justify-between">
            <div class="flex-1">
              <div class="font-medium text-green-800 dark:text-green-200">${schoolData.name}</div>
              <div class="text-sm text-green-600 dark:text-green-400">${schoolData.address}</div>
              <div class="text-xs text-green-500 dark:text-green-500">${schoolData.city} - ${schoolData.state} • ${schoolData.type}</div>
            </div>
            <button type="button"
                    class="ml-2 text-green-600 hover:text-green-800 dark:text-green-400 dark:hover:text-green-200"
                    data-action="click->school-search#clearSelection">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
              </svg>
            </button>
          </div>
        </div>
      `
    }
  }

  clearSelection() {
    this.selectedSchoolData = null
    this.inputTarget.value = ''
    this.hideResults()

    if (this.hasSelectedSchoolTarget) {
      this.selectedSchoolTarget.innerHTML = ''
    }
  }

  showLoading() {
    this.resultsTarget.innerHTML = `
      <div class="p-3 text-sm text-gray-500 text-center">
        <div class="flex items-center justify-center gap-2">
          <svg class="animate-spin w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
          </svg>
          Buscando escolas...
        </div>
      </div>
    `
    this.showResults()
  }

  showError(message) {
    this.resultsTarget.innerHTML = `
      <div class="p-3 text-sm text-red-600 dark:text-red-400 text-center">
        ${message}
      </div>
    `
    this.showResults()
  }

  showResults() {
    this.resultsTarget.classList.remove('hidden')
  }

  hideResults() {
    this.resultsTarget.classList.add('hidden')
  }

  // Esconder resultados quando clicar fora
  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hideResults()
    }
  }
}
