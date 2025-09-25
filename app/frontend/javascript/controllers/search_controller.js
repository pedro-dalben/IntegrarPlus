import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['input', 'results', 'form'];
  static values = { url: String };

  connect() {
    this.debouncedSearch = this.debounce(this.performSearch.bind(this), 500);
    this.isSearching = false;
  }

  search() {
    if (this.inputTarget.value.trim().length > 0) {
      this.debouncedSearch();
    } else {
      this.clearSearch();
    }
  }

  async performSearch() {
    const query = this.inputTarget.value.trim();

    if (query.length === 0) {
      this.clearSearch();
      return;
    }

    this.isSearching = true;
    this.showLoading();

    try {
      const url = new URL(this.urlValue, window.location.origin);
      url.searchParams.set('query', query);
      url.searchParams.set('page', '1');

      const response = await fetch(url.toString(), {
        headers: {
          Accept: 'text/html',
          'X-Requested-With': 'XMLHttpRequest',
        },
      });

      if (response.ok) {
        const html = await response.text();
        this.updateResults(html);
      }
    } catch (error) {
      this.showError();
    } finally {
      this.isSearching = false;
      this.hideLoading();
    }
  }

  clearSearch() {
    this.inputTarget.value = '';

    const url = new URL(window.location);
    url.searchParams.delete('query');
    url.searchParams.delete('page');
    window.history.pushState({}, '', url);

    window.location.reload();
  }

  updateResults(html) {
    const url = new URL(window.location);
    const query = this.inputTarget.value.trim();

    if (query.length > 0) {
      url.searchParams.set('query', query);
      url.searchParams.set('page', '1');
    } else {
      url.searchParams.delete('query');
      url.searchParams.delete('page');
    }

    window.history.pushState({}, '', url);

    const parser = new DOMParser();
    const doc = parser.parseFromString(html, 'text/html');

    if (this.hasResultsTarget) {
      const newResults = doc.querySelector('[data-search-target="results"]');
      if (newResults) {
        this.resultsTarget.innerHTML = newResults.innerHTML;
        this.inputTarget.value = query;
        return;
      }
    }

    let currentContainer = document.querySelector(
      '.overflow-hidden.rounded-xl.border.border-gray-200.bg-white'
    );
    let newContainer = doc.querySelector(
      '.overflow-hidden.rounded-xl.border.border-gray-200.bg-white'
    );

    if (currentContainer && newContainer) {
      currentContainer.replaceWith(newContainer);
    } else {
      currentContainer = document.querySelector(
        '.bg-white.dark\\:bg-gray-800.shadow-md.rounded-lg.overflow-hidden'
      );
      newContainer = doc.querySelector(
        '.bg-white.dark\\:bg-gray-800.shadow-md.rounded-lg.overflow-hidden'
      );

      if (currentContainer && newContainer) {
        currentContainer.replaceWith(newContainer);
      } else {
        const currentTable = document.querySelector('table');
        const newTable = doc.querySelector('table');

        if (currentTable && newTable) {
          const tableContainer = currentTable.closest('.overflow-hidden, .bg-white, .shadow-md');
          const newTableContainer = newTable.closest('.overflow-hidden, .bg-white, .shadow-md');

          if (tableContainer && newTableContainer) {
            tableContainer.replaceWith(newTableContainer);
          } else {
            currentTable.replaceWith(newTable);
          }
        }
      }
    }

    this.updatePagination(doc);
    this.inputTarget.value = query;
  }

  updatePagination(doc) {
    const paginationSelectors = [
      '[data-controller*="pagination"]',
      '[aria-label="Pagination"]',
      '.pagination',
      '.bg-white.dark\\:bg-gray-800.px-4.py-3',
    ];

    let currentPagination = null;
    let newPagination = null;

    for (const selector of paginationSelectors) {
      currentPagination = document.querySelector(selector);
      if (currentPagination) break;
    }

    for (const selector of paginationSelectors) {
      newPagination = doc.querySelector(selector);
      if (newPagination) break;
    }

    if (currentPagination && newPagination) {
      currentPagination.replaceWith(newPagination);
    } else if (newPagination) {
      const tableContainer = document.querySelector(
        '.overflow-hidden.rounded-xl.border.border-gray-200.bg-white, .bg-white.dark\\:bg-gray-800.shadow-md.rounded-lg.overflow-hidden'
      );
      if (tableContainer) {
        tableContainer.parentNode.appendChild(newPagination);
      }
    }
  }

  showLoading() {
    const loadingIndicator = document.createElement('div');
    loadingIndicator.id = 'search-loading';
    loadingIndicator.className =
      'absolute inset-0 bg-white bg-opacity-75 flex items-center justify-center z-10';
    loadingIndicator.innerHTML =
      '<div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>';

    if (this.hasResultsTarget) {
      this.resultsTarget.style.position = 'relative';
      this.resultsTarget.appendChild(loadingIndicator);
    }
  }

  hideLoading() {
    const loadingIndicator = document.getElementById('search-loading');
    if (loadingIndicator) {
      loadingIndicator.remove();
    }
  }

  showError() {
  }

  debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout);
        func(...args);
      };
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
    };
  }
}
