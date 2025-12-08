import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['tab', 'panes'];
  static values = {
    fetchUrl: String,
    resourceId: String,
    resourceType: String,
  };

  connect() {
    this.setupTurboListeners();
    setTimeout(() => {
      this.initializeTab();
    }, 100);
  }

  disconnect() {
    document.removeEventListener('turbo:load', this.boundRefreshTabs);
    document.removeEventListener('turbo:render', this.boundRefreshTabs);
  }

  setupTurboListeners() {
    this.boundRefreshTabs = this.refreshTabs.bind(this);
    document.addEventListener('turbo:load', this.boundRefreshTabs);
    document.addEventListener('turbo:render', this.boundRefreshTabs);
  }

  async refreshTabs() {
    await new Promise(resolve => setTimeout(resolve, 100));
    
    const urlParams = new URLSearchParams(window.location.search);
    const tabParam = urlParams.get('tab');
    const hash = window.location.hash.replace('#', '');
    const activeTab = tabParam || hash;

    if (activeTab) {
      setTimeout(() => {
        this.switchToTab(activeTab, false);
      }, 200);
    } else {
      const [firstTab] = this.tabTargets;
      if (firstTab) {
        setTimeout(() => {
          this.switchToTab(firstTab.dataset.key, false);
        }, 200);
      }
    }
  }

  async createMissingPanes() {
    const allPanes = Array.from(this.panesTarget.children).filter(child => child.hasAttribute('data-key'));
    const seenKeys = new Map();
    const duplicatePanes = [];
    
    allPanes.forEach((pane) => {
      const { key } = pane.dataset;
      if (seenKeys.has(key)) {
        duplicatePanes.push(pane);
      } else {
        seenKeys.set(key, pane);
      }
    });
    
    duplicatePanes.forEach(pane => {
      pane.remove();
    });
    
    const allTabKeys = this.tabTargets.map(t => t.dataset.key);
    const existingKeys = new Set(Array.from(this.panesTarget.children).filter(child => child.hasAttribute('data-key')).map(p => p.dataset.key));
    const missingKeys = allTabKeys.filter(key => !existingKeys.has(key));
    
    if (missingKeys.length === 0) {
      const emptyPanes = Array.from(this.panesTarget.children).filter(child => child.hasAttribute('data-key')).filter(p => 
        p.innerHTML.trim().length < 50 && p.dataset.loaded !== 'true'
      );
      if (emptyPanes.length > 0) {
        for (const pane of emptyPanes) {
          await this.loadPaneContentDirectly(pane.dataset.key, pane);
        }
      }
      return;
    }
    
    for (const key of missingKeys) {
      const pane = document.createElement('div');
      pane.dataset.key = key;
      pane.dataset.turboCache = 'false';
      pane.style.display = 'none';
      this.panesTarget.appendChild(pane);
      await this.loadPaneContentDirectly(key, pane);
    }
  }

  initializeTab() {
    const urlParams = new URLSearchParams(window.location.search);
    const tabParam = urlParams.get('tab');
    const hash = window.location.hash.replace('#', '');
    const initialTab = tabParam || hash;

    if (initialTab) {
      this.switchToTab(initialTab, false);
    } else {
      const [firstTab] = this.tabTargets;
      if (firstTab) {
        this.switchToTab(firstTab.dataset.key, false);
      }
    }
  }

  switch(event) {
    event.preventDefault();
    const { key } = event.currentTarget.dataset;
    this.switchToTab(key, true);
  }

  async switchToTab(key, updateUrl = true) {
    const tabElement = this.tabTargets.find(el => el.dataset.key === key);
    if (!tabElement) {
      return;
    }

    this.tabTargets.forEach(el => {
      el.setAttribute('aria-selected', 'false');
      el.classList.remove('border-brand-500', 'text-brand-600');
      el.classList.add('border-transparent', 'text-gray-500');
    });

    tabElement.setAttribute('aria-selected', 'true');
    tabElement.classList.remove('border-transparent', 'text-gray-500');
    tabElement.classList.add('border-brand-500', 'text-brand-600');

    if (!this.panesTarget) {
      return;
    }

    const panes = Array.from(this.panesTarget.children).filter(child => child.hasAttribute('data-key'));
    const targetPane = panes.find(p => p.dataset.key === key);
    if (!targetPane) {
      const url = new URL(window.location);
      url.searchParams.set('tab', key);
      url.hash = key;
      window.location.href = url.toString();
      return;
    }

    panes.forEach((pane) => {
      const isActive = pane.dataset.key === key;
      if (isActive) {
        pane.removeAttribute('style');
        pane.removeAttribute('hidden');
      } else {
        pane.setAttribute('style', 'display: none;');
      }
    });

    if (updateUrl) {
      const url = new URL(window.location);
      url.searchParams.set('tab', key);
      url.hash = key;
      window.history.pushState({}, '', url);
    }
  }

  async loadPaneContentDirectly(key, pane = null) {
    if (!this.hasFetchUrlValue) {
      return;
    }

    if (!pane) {
      pane = Array.from(this.panesTarget.children).filter(child => child.hasAttribute('data-key')).find(p => p.dataset.key === key);
    }
    
    if (pane && pane.dataset.loaded === 'true' && pane.innerHTML.trim().length > 50) {
      return;
    }

    try {
      const url = new URL(this.fetchUrlValue, window.location.origin);
      url.searchParams.delete('tab');
      const response = await fetch(url.toString(), {
        headers: {
          'Accept': 'text/html',
          'X-Requested-With': 'XMLHttpRequest',
        },
      });

      if (!response.ok) {
        return;
      }

      const html = await response.text();
      const panesContainerStart = html.indexOf('data-tabs-target="panes"');
      if (panesContainerStart === -1) {
        return;
      }
      
      const afterPanesStart = html.substring(panesContainerStart);
      const paneRegex = new RegExp(`<div[^>]*data-key="${key}"[^>]*>([\\s\\S]*?)</div>\\s*(?=<div[^>]*data-key=|</div>\\s*</div>\\s*</div>)`, 'i');
      const paneMatch = afterPanesStart.match(paneRegex);
      
      if (paneMatch && paneMatch[1]) {
        if (!pane) {
          pane = document.createElement('div');
          pane.dataset.key = key;
          pane.dataset.turboCache = 'false';
          pane.style.display = 'none';
          this.panesTarget.appendChild(pane);
        }
        pane.innerHTML = paneMatch[1].trim();
        pane.dataset.loaded = 'true';
      } else {
        const parser = new DOMParser();
        const doc = parser.parseFromString(html, 'text/html');
        
        const tabsContainer = doc.querySelector('[data-controller="tabs"]');
        if (!tabsContainer) {
          return;
        }
        
        const panesContainer = tabsContainer.querySelector('[data-tabs-target="panes"]');
        if (!panesContainer) {
          return;
        }
        
        const newPane = panesContainer.querySelector(`[data-key="${key}"]`);

        if (newPane) {
          if (!pane) {
            pane = document.createElement('div');
            pane.dataset.key = key;
            pane.dataset.turboCache = 'false';
            pane.style.display = 'none';
            this.panesTarget.appendChild(pane);
          }
          pane.innerHTML = newPane.innerHTML;
          pane.dataset.loaded = 'true';
        }
      }
    } catch {
      // Ignore errors when loading pane content
    }
  }

  async loadPaneContent(key, pane) {
    if (!this.hasFetchUrlValue) {
      return;
    }

    if (pane.dataset.loaded === 'true') {
      return;
    }

    await this.loadPaneContentDirectly(key);
  }
}
