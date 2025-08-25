import { Controller } from '@hotwired/stimulus';

const K = { SIDEBAR: 'ui:sidebarOpen', DARK: 'ui:dark' };

export default class extends Controller {
  static targets = ['searchInput'];

  connect() {
    // aplicar tema salvo
    const dark = localStorage.getItem(K.DARK) === 'true';
    document.documentElement.classList.toggle('dark', dark);

    // Debounce para evitar eventos duplos
    this._debounceTimeout = null;
  }

  toggleSidebar() {
    // Debounce para evitar eventos duplos
    if (this._debounceTimeout) {
      clearTimeout(this._debounceTimeout);
    }

    this._debounceTimeout = setTimeout(() => {
      const current = localStorage.getItem(K.SIDEBAR) === 'true';
      const next = !current;
      localStorage.setItem(K.SIDEBAR, String(next));
      window.dispatchEvent(new CustomEvent('ui:sidebar', { detail: { open: next } }));
    }, 100);
  }

  toggleDark() {
    const next = !document.documentElement.classList.contains('dark');
    document.documentElement.classList.toggle('dark', next);
    localStorage.setItem(K.DARK, String(next));
  }

  focusSearch() {
    if (this.hasSearchInputTarget) this.searchInputTarget.focus();
  }

  disconnect() {
    if (this._debounceTimeout) {
      clearTimeout(this._debounceTimeout);
    }
  }
}
