import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['tab', 'panes'];

  connect() {
    const urlParams = new URLSearchParams(window.location.search);
    const tabParam = urlParams.get('tab');
    const hash = window.location.hash.replace('#', '');
    const initialTab = tabParam || hash;

    setTimeout(() => {
      if (initialTab) {
        this.switchToTab(initialTab, false);
      } else {
        const firstTab = this.tabTargets[0];
        if (firstTab) {
          this.switchToTab(firstTab.dataset.key, false);
        }
      }
    }, 0);
  }

  switch(event) {
    event.preventDefault();
    const key = event.currentTarget.dataset.key;
    this.switchToTab(key, true);
  }

  switchToTab(key, updateUrl = true) {
    const tabElement = this.tabTargets.find(el => el.dataset.key === key);
    if (!tabElement) return;

    this.tabTargets.forEach(el => {
      el.setAttribute('aria-selected', 'false');
      el.classList.remove('border-brand-500', 'text-brand-600');
      el.classList.add('border-transparent', 'text-gray-500');
    });

    tabElement.setAttribute('aria-selected', 'true');
    tabElement.classList.remove('border-transparent', 'text-gray-500');
    tabElement.classList.add('border-brand-500', 'text-brand-600');

    const panes = this.panesTarget.querySelectorAll('[data-key]');
    panes.forEach(pane => {
      pane.style.display = pane.dataset.key === key ? '' : 'none';
    });

    if (updateUrl) {
      const url = new URL(window.location);
      url.searchParams.set('tab', key);
      url.hash = key;
      window.history.pushState({}, '', url);
    }
  }
}
