import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['tab', 'panes'];
  static values = {
    fetchUrl: String,
    resourceId: String,
    resourceType: String,
  };

  connect() {
    console.log('[TabsController] Controller conectado', this.element);
    console.log('[TabsController] Tabs encontradas:', this.tabTargets.length);
    
    const panes = this.panesTarget ? Array.from(this.panesTarget.children).filter(child => child.hasAttribute('data-key')) : [];
    console.log('[TabsController] Panes encontrados:', panes.length);
    panes.forEach((pane, index) => {
      console.log(`[TabsController] Pane ${index}:`, pane.dataset.key, pane);
    });
    
    if (this.tabTargets.length > 1 && panes.length < this.tabTargets.length) {
      console.warn('[TabsController] Aviso: Número de panes menor que tabs! Criando panes faltantes...');
      console.warn('[TabsController] Tabs:', this.tabTargets.length, 'Panes:', panes.length);
      this.createMissingPanes();
    }
    
    this.setupTurboListeners();
    
    setTimeout(() => {
      this.initializeTab();
    }, 100);
  }

  disconnect() {
    console.log('[TabsController] Controller desconectado');
    document.removeEventListener('turbo:load', this.boundRefreshTabs);
    document.removeEventListener('turbo:render', this.boundRefreshTabs);
  }

  setupTurboListeners() {
    console.log('[TabsController] Configurando listeners do Turbo');
    this.boundRefreshTabs = this.refreshTabs.bind(this);
    document.addEventListener('turbo:load', this.boundRefreshTabs);
    document.addEventListener('turbo:render', this.boundRefreshTabs);
    console.log('[TabsController] Listeners do Turbo configurados');
  }

  async refreshTabs() {
    console.log('[TabsController] refreshTabs chamado');
    
    await new Promise(resolve => setTimeout(resolve, 100));
    
    const panes = this.panesTarget ? Array.from(this.panesTarget.children).filter(child => child.hasAttribute('data-key')) : [];
    console.log('[TabsController] Panes encontrados no refresh:', panes.length);
    panes.forEach((pane, index) => {
      console.log(`[TabsController] Pane ${index} no refresh:`, pane.dataset.key);
    });
    
    if (this.tabTargets.length > 0 && panes.length < this.tabTargets.length) {
      console.warn('[TabsController] Aviso no refresh: Número de panes menor que tabs!');
      console.warn('[TabsController] Tabs:', this.tabTargets.length, 'Panes:', panes.length);
      console.warn('[TabsController] Tentando criar panes faltantes...');
      await this.createMissingPanes();
      const newPanes = this.panesTarget ? Array.from(this.panesTarget.children).filter(child => child.hasAttribute('data-key')) : [];
      console.log('[TabsController] Panes após criar faltantes:', newPanes.length);
    }
    
    const urlParams = new URLSearchParams(window.location.search);
    const tabParam = urlParams.get('tab');
    const hash = window.location.hash.replace('#', '');
    const activeTab = tabParam || hash;
    
    console.log('[TabsController] Tab param:', tabParam);
    console.log('[TabsController] Hash:', hash);
    console.log('[TabsController] Active tab:', activeTab);

    if (activeTab) {
      setTimeout(() => {
        console.log('[TabsController] Mudando para aba:', activeTab);
        this.switchToTab(activeTab, false);
      }, 200);
    } else {
      const firstTab = this.tabTargets[0];
      if (firstTab) {
        setTimeout(() => {
          console.log('[TabsController] Ativando primeira aba:', firstTab.dataset.key);
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
      const key = pane.dataset.key;
      if (seenKeys.has(key)) {
        duplicatePanes.push(pane);
      } else {
        seenKeys.set(key, pane);
      }
    });
    
    duplicatePanes.forEach(pane => {
      console.log('[TabsController] Removendo pane duplicado:', pane.dataset.key);
      pane.remove();
    });
    
    if (duplicatePanes.length > 0) {
      console.log('[TabsController] Panes duplicados removidos:', duplicatePanes.length);
    }
    
    const allTabKeys = this.tabTargets.map(t => t.dataset.key);
    const existingKeys = new Set(Array.from(this.panesTarget.children).filter(child => child.hasAttribute('data-key')).map(p => p.dataset.key));
    const missingKeys = allTabKeys.filter(key => !existingKeys.has(key));
    
    console.log('[TabsController] Criando panes faltantes:', missingKeys);
    
    if (missingKeys.length === 0) {
      const emptyPanes = Array.from(this.panesTarget.children).filter(child => child.hasAttribute('data-key')).filter(p => 
        p.innerHTML.trim().length < 50 && p.dataset.loaded !== 'true'
      );
      if (emptyPanes.length > 0) {
        console.log('[TabsController] Carregando conteúdo para panes vazios:', emptyPanes.map(p => p.dataset.key));
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
      console.log('[TabsController] Pane criado e carregado:', key);
    }
  }

  initializeTab() {
    console.log('[TabsController] Inicializando aba');
    const urlParams = new URLSearchParams(window.location.search);
    const tabParam = urlParams.get('tab');
    const hash = window.location.hash.replace('#', '');
    const initialTab = tabParam || hash;
    
    console.log('[TabsController] Initial tab:', initialTab);

    setTimeout(() => {
      if (initialTab) {
        console.log('[TabsController] Mudando para aba inicial:', initialTab);
        this.switchToTab(initialTab, false);
      } else {
        const firstTab = this.tabTargets[0];
        if (firstTab) {
          console.log('[TabsController] Usando primeira aba:', firstTab.dataset.key);
          this.switchToTab(firstTab.dataset.key, false);
        }
      }
    }, 0);
  }

  async switch(event) {
    console.log('[TabsController] Switch chamado', event.currentTarget.dataset.key);
    event.preventDefault();
    const key = event.currentTarget.dataset.key;
    await this.switchToTab(key, true);
  }

  async switchToTab(key, updateUrl = true) {
    console.log('[TabsController] switchToTab chamado:', key, 'updateUrl:', updateUrl);
    const tabElement = this.tabTargets.find(el => el.dataset.key === key);
    if (!tabElement) {
      console.warn('[TabsController] Tab element não encontrado para key:', key);
      console.warn('[TabsController] Tabs disponíveis:', this.tabTargets.map(t => t.dataset.key));
      return;
    }

    console.log('[TabsController] Tab element encontrado:', tabElement);

    this.tabTargets.forEach(el => {
      el.setAttribute('aria-selected', 'false');
      el.classList.remove('border-brand-500', 'text-brand-600');
      el.classList.add('border-transparent', 'text-gray-500');
    });

    tabElement.setAttribute('aria-selected', 'true');
    tabElement.classList.remove('border-transparent', 'text-gray-500');
    tabElement.classList.add('border-brand-500', 'text-brand-600');

    if (!this.panesTarget) {
      console.error('[TabsController] panesTarget não encontrado!');
      return;
    }

    let panes = Array.from(this.panesTarget.children).filter(child => child.hasAttribute('data-key'));
    console.log('[TabsController] Panes encontrados:', panes.length);
    let targetPane = panes.find(p => p.dataset.key === key);

    if (!targetPane) {
      console.warn(`[TabsController] Pane não encontrado para key: ${key}. Tentando criar...`);
      await this.loadPaneContentDirectly(key);
      panes = Array.from(this.panesTarget.children).filter(child => child.hasAttribute('data-key'));
      targetPane = panes.find(p => p.dataset.key === key);
      
      if (!targetPane) {
        console.warn(`[TabsController] Pane ainda não encontrado após criar. Recarregando página com tab=${key}...`);
        const url = new URL(window.location);
        url.searchParams.set('tab', key);
        url.hash = key;
        window.location.href = url.toString();
        return;
      }
    }

    panes.forEach((pane, index) => {
      const isActive = pane.dataset.key === key;
      if (isActive) {
        pane.removeAttribute('style');
        pane.removeAttribute('hidden');
        pane.classList.remove('hidden');
        pane.style.display = '';
      } else {
        pane.style.display = 'none';
        pane.setAttribute('hidden', '');
        pane.classList.add('hidden');
      }
      console.log(`[TabsController] Pane ${index} (${pane.dataset.key}): ${isActive ? 'visível' : 'oculto'}`);
    });
    
    if (targetPane) {
      targetPane.removeAttribute('style');
      targetPane.removeAttribute('hidden');
      targetPane.classList.remove('hidden');
      targetPane.style.display = '';
      
      console.log('[TabsController] Pane ativo garantido como visível:', key);
      console.log('[TabsController] Pane display style:', targetPane.style.display);
      console.log('[TabsController] Pane computed style:', window.getComputedStyle(targetPane).display);
    }

    if (updateUrl) {
      const url = new URL(window.location);
      url.searchParams.set('tab', key);
      url.hash = key;
      window.history.pushState({}, '', url);
      console.log('[TabsController] URL atualizada:', url.toString());
    }
  }

  async loadPaneContentDirectly(key, pane = null) {
    if (!this.hasFetchUrlValue) {
      console.warn('[TabsController] fetchUrlValue não definido; não é possível carregar conteúdo dinamicamente.');
      return;
    }

    if (!pane) {
      pane = Array.from(this.panesTarget.children).filter(child => child.hasAttribute('data-key')).find(p => p.dataset.key === key);
    }
    
    if (pane && pane.dataset.loaded === 'true' && pane.innerHTML.trim().length > 50) {
      console.log('[TabsController] Pane já carregado e com conteúdo:', key);
      return;
    }

    try {
      // Busque SEM o parâmetro tab para obter TODOS os panes
      const url = new URL(this.fetchUrlValue, window.location.origin);
      url.searchParams.delete('tab'); // Remova o parâmetro tab para obter todos os panes
      const response = await fetch(url.toString(), {
        headers: {
          'Accept': 'text/html',
          'X-Requested-With': 'XMLHttpRequest',
        },
      });

      if (!response.ok) {
        console.error('[TabsController] Falha ao carregar conteúdo da aba', key, response.status);
        return;
      }

      const html = await response.text();
      
      // Use regex para extrair o conteúdo do pane diretamente do HTML
      // Isso é mais confiável do que usar DOMParser, que pode ter problemas com HTML complexo
      const panesContainerStart = html.indexOf('data-tabs-target="panes"');
      if (panesContainerStart === -1) {
        console.warn('[TabsController] Container de panes não encontrado no HTML');
        return;
      }
      
      // Encontre o início do container de panes e procure pelo pane específico
      const afterPanesStart = html.substring(panesContainerStart);
      const paneRegex = new RegExp(`<div[^>]*data-key="${key}"[^>]*>([\\s\\S]*?)</div>\\s*(?=<div[^>]*data-key=|</div>\\s*</div>\\s*</div>)`, 'i');
      const paneMatch = afterPanesStart.match(paneRegex);
      
      if (paneMatch && paneMatch[1]) {
        // Crie o pane se não existir
        if (!pane) {
          pane = document.createElement('div');
          pane.dataset.key = key;
          pane.dataset.turboCache = 'false';
          pane.style.display = 'none';
          this.panesTarget.appendChild(pane);
        }
        pane.innerHTML = paneMatch[1].trim();
        pane.dataset.loaded = 'true';
        console.log('[TabsController] Conteúdo carregado diretamente para a aba', key);
      } else {
        // Fallback: tente usar DOMParser
        const parser = new DOMParser();
        const doc = parser.parseFromString(html, 'text/html');
        
        const tabsContainer = doc.querySelector('[data-controller="tabs"]');
        if (!tabsContainer) {
          console.warn('[TabsController] Container de tabs não encontrado na resposta');
          return;
        }
        
        const panesContainer = tabsContainer.querySelector('[data-tabs-target="panes"]');
        if (!panesContainer) {
          console.warn('[TabsController] Container de panes não encontrado na resposta');
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
          console.log('[TabsController] Conteúdo carregado via DOMParser para a aba', key);
        } else {
          console.warn('[TabsController] Pane não encontrado na resposta para key:', key);
          const availablePanes = Array.from(panesContainer.children).filter(child => child.hasAttribute('data-key'));
          console.warn('[TabsController] Panes disponíveis na resposta:', availablePanes.map(p => p.dataset.key));
        }
      }
    } catch (error) {
      console.error('[TabsController] Erro ao carregar conteúdo da aba:', error);
    }
  }

  async loadPaneContent(key, pane) {
    if (!this.hasFetchUrlValue) {
      console.warn('[TabsController] fetchUrlValue não definido; não é possível carregar conteúdo dinamicamente.');
      return;
    }

    if (pane.dataset.loaded === 'true') {
      console.log('[TabsController] Pane já carregado:', key);
      return;
    }

    await this.loadPaneContentDirectly(key);
  }
}
