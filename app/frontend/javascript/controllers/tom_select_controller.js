import { Controller } from '@hotwired/stimulus';
import TomSelect from 'tom-select';

export default class extends Controller {
  static targets = ['select'];
  static values = {
    options: Object,
    url: String,
    valuefield: String,
    labelfield: String,
    searchfield: String,
  };

  connect() {
    this.hideOriginalSelect();

    const baseOptions = {
      plugins: ['remove_button', 'dropdown_input'],
      itemClass: 'ts-item-integrated',
      render: {
        option(data, escape) {
          const text = data.text || data.label || data.name || '';
          return `<div class="option-item">${escape(text)}</div>`;
        },
        item(data, escape) {
          const text = data.text || data.label || data.name || '';
          return `<div class="item-tag">${escape(text)}</div>`;
        },
      },
    };

    const remoteOptions = this.hasUrlValue ? this.buildRemoteOptions() : {};

    this.tomSelect = new TomSelect(this.selectTarget, {
      ...baseOptions,
      ...remoteOptions,
      ...(this.hasOptionsValue ? this.optionsValue : {}),
    });

    this.selectTarget.tomSelect = this.tomSelect;
    this.element.dispatchEvent(new CustomEvent('tom-select:connected', { bubbles: true }));
  }

  buildRemoteOptions() {
    const valueField = this.hasValuefieldValue ? this.valuefieldValue : 'id';
    const labelField = this.hasLabelfieldValue ? this.labelfieldValue : 'name';
    const searchField = this.hasSearchfieldValue ? this.searchfieldValue : 'name';

    return {
      valueField,
      labelField,
      searchField,
      preload: 'focus',
      load: (query, callback) => {
        const url = `${this.urlValue}?search=${encodeURIComponent(query || '')}`;
        fetch(url, { headers: { Accept: 'application/json' } })
          .then(res => res.json())
          .then(json => {
            const items = Array.isArray(json) ? json : json.professionals || [];
            callback(items);
          })
          .catch(() => callback());
      },
    };
  }

  hideOriginalSelect() {
    if (this.hasSelectTarget) {
      this.selectTarget.style.display = 'none';
    }
  }

  disconnect() {
    if (this.tomSelect) {
      this.tomSelect.destroy();
    }
    if (this.hasSelectTarget) {
      this.selectTarget.style.display = '';
    }
  }
}
