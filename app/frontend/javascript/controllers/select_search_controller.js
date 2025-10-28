import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['input', 'dropdown', 'options', 'selectedOption'];
  static values = {
    placeholder: String,
    searchUrl: String,
    selectedId: String,
    selectedText: String,
  };

  connect() {
    this.isOpen = false;
    this.filteredOptions = [];
    this.allOptions = [];
    this.setupEventListeners();
    this.loadInitialOptions();
  }

  setupEventListeners() {
    document.addEventListener('click', e => {
      if (!this.element.contains(e.target)) {
        this.closeDropdown();
      }
    });

    this.inputTarget.addEventListener('focus', () => {
      this.openDropdown();
    });

    this.inputTarget.addEventListener('input', e => {
      this.filterOptions(e.target.value);
    });

    this.inputTarget.addEventListener('keydown', e => {
      this.handleKeydown(e);
    });
  }

  loadInitialOptions() {
    if (this.hasSearchUrlValue) {
      this.fetchOptions();
    } else {
      this.allOptions = Array.from(this.optionsTarget.children).map(option => ({
        id: option.value,
        text: option.textContent,
        element: option,
      }));
      this.filteredOptions = [...this.allOptions];
    }
  }

  async fetchOptions() {
    try {
      const response = await fetch(this.searchUrlValue);
      const data = await response.json();
      this.allOptions = data.map(item => ({
        id: item.id,
        text: item.name || item.full_name || item.text,
        data: item,
      }));
      this.filteredOptions = [...this.allOptions];
      this.renderOptions();
    } catch (error) {}
  }

  filterOptions(searchTerm) {
    if (!searchTerm) {
      this.filteredOptions = [...this.allOptions];
    } else {
      this.filteredOptions = this.allOptions.filter(option =>
        option.text.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }
    this.renderOptions();
  }

  renderOptions() {
    this.optionsTarget.innerHTML = '';

    if (this.filteredOptions.length === 0) {
      this.optionsTarget.innerHTML =
        '<div class="px-3 py-2 text-sm text-gray-500">Nenhum resultado encontrado</div>';
      return;
    }

    this.filteredOptions.forEach(option => {
      const optionElement = document.createElement('div');
      optionElement.className = 'px-3 py-2 text-sm text-gray-700 hover:bg-gray-100 cursor-pointer';
      optionElement.textContent = option.text;
      optionElement.dataset.value = option.id;
      optionElement.addEventListener('click', () => this.selectOption(option));
      this.optionsTarget.appendChild(optionElement);
    });
  }

  selectOption(option) {
    this.selectedIdValue = option.id;
    this.selectedTextValue = option.text;
    this.inputTarget.value = option.text;
    this.closeDropdown();

    this.dispatch('change', { detail: { id: option.id, text: option.text, data: option.data } });
  }

  openDropdown() {
    this.isOpen = true;
    this.dropdownTarget.classList.remove('hidden');
    this.renderOptions();
  }

  closeDropdown() {
    this.isOpen = false;
    this.dropdownTarget.classList.add('hidden');
  }

  handleKeydown(event) {
    switch (event.key) {
      case 'Escape':
        this.closeDropdown();
        break;
      case 'Enter':
        event.preventDefault();
        if (this.filteredOptions.length === 1) {
          this.selectOption(this.filteredOptions[0]);
        }
        break;
      case 'ArrowDown':
        event.preventDefault();
        this.navigateOptions(1);
        break;
      case 'ArrowUp':
        event.preventDefault();
        this.navigateOptions(-1);
        break;
    }
  }

  navigateOptions(direction) {
    const options = this.optionsTarget.querySelectorAll('div[data-value]');
    const currentIndex = Array.from(options).findIndex(option =>
      option.classList.contains('bg-blue-100')
    );

    options.forEach(option => option.classList.remove('bg-blue-100'));

    let newIndex = currentIndex + direction;
    if (newIndex < 0) newIndex = options.length - 1;
    if (newIndex >= options.length) newIndex = 0;

    if (options[newIndex]) {
      options[newIndex].classList.add('bg-blue-100');
    }
  }

  toggleDropdown() {
    if (this.isOpen) {
      this.closeDropdown();
    } else {
      this.openDropdown();
    }
  }
}
