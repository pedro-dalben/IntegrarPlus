import { Controller } from '@hotwired/stimulus';

const K = { SIDEBAR: 'ui:sidebarOpen' };

export default class extends Controller {
  static targets = ['overlay'];

  connect() {
    console.log("🔧 SidebarController conectado");
    
    // estado inicial baseado no tamanho da tela e preferência salva
    const isDesktop = window.innerWidth >= 1280;
    const savedState = localStorage.getItem(K.SIDEBAR) === 'true';

    // Em desktop: usar estado salvo ou padrão aberto, em mobile: fechada inicialmente
    const shouldBeOpen = isDesktop ? (savedState !== null ? savedState : true) : false;

    // Aplicar estado inicial com inline styles
    if (isDesktop) {
      this.element.style.position = 'static';
      this.element.style.transform = '';
      this.element.classList.remove('fixed');
    } else {
      this.element.style.position = 'fixed';
      this.element.style.transform = 'translateX(-100%)';
      this.element.classList.add('fixed');
    }

    this.apply(shouldBeOpen);

    // Debounce para evitar eventos duplos
    this._debounceTimeout = null;
    this._sync = e => {
      // Clear previous timeout
      if (this._debounceTimeout) {
        clearTimeout(this._debounceTimeout);
      }

      // Debounce the apply call
      this._debounceTimeout = setTimeout(() => {
        this.apply(!!e.detail?.open);
      }, 10);
    };
    window.addEventListener('ui:sidebar', this._sync);

    // Ao navegar, feche apenas em mobile
    document.addEventListener('turbo:load', () => {
      if (window.innerWidth < 1280) this.apply(false);
    });

    // Fechar sidebar em mobile ao clicar em links
    this._linkClickHandler = e => {
      const link = e.target.closest('a');
      if (link && link.getAttribute('href') !== '#' && window.innerWidth < 1280) {
        // Pequeno delay para permitir a navegação
        setTimeout(() => {
          this.apply(false);
        }, 100);
      }
    };
    this.element.addEventListener('click', this._linkClickHandler);

    // Ao redimensionar a janela
    this._resizeHandler = () => {
      const isDesktop = window.innerWidth >= 1280;
      const currentState = localStorage.getItem(K.SIDEBAR) === 'true';
      
      // Em desktop: manter estado atual, em mobile: fechar se estiver aberto
      let shouldBeOpen;
      if (isDesktop) {
        shouldBeOpen = currentState;
      } else {
        shouldBeOpen = false;
      }
      
      this.apply(shouldBeOpen);
    };

    window.addEventListener('resize', this._resizeHandler);
  }

  disconnect() {
    window.removeEventListener('ui:sidebar', this._sync);
    if (this._resizeHandler) {
      window.removeEventListener('resize', this._resizeHandler);
    }
    if (this._linkClickHandler) {
      this.element.removeEventListener('click', this._linkClickHandler);
    }
    if (this._debounceTimeout) {
      clearTimeout(this._debounceTimeout);
    }
  }

  // click fora (bind no window)
  outside(e) {
    const isDesktop = window.innerWidth >= 1280;
    if (isDesktop) return;

    // Verificar se o click foi no botão hambúrguer
    const hamburger = document.querySelector('[data-action="click->header#toggleSidebar"]');
    if (hamburger && hamburger.contains(e.target)) {
      return;
    }

    // Verificar se o click foi em um dropdown
    const dropdown = e.target.closest('[data-controller="dropdown"]');
    if (dropdown) {
      return;
    }

    // Verificar se o click foi em um elemento do header
    const header = e.target.closest('[data-controller="header"]');
    if (header) {
      return;
    }

    if (!this.element.contains(e.target)) {
      this.apply(false);
    }
  }

  toggle() {
    console.log("🔧 SidebarController toggle chamado");
    const currentState = localStorage.getItem(K.SIDEBAR) === 'true';
    console.log("🔧 Estado atual:", currentState, "-> Novo estado:", !currentState);
    this.apply(!currentState);
  }

  apply(open) {
    console.log("🔧 SidebarController apply chamado com:", open);
    localStorage.setItem(K.SIDEBAR, String(open));

    // Em desktop: permitir ocultar/mostrar, em mobile: controlar com transform
    const isDesktop = window.innerWidth >= 1280;
    console.log("🔧 É desktop?", isDesktop);

    if (isDesktop) {
      if (open) {
        // Desktop: sidebar visível - position static para ocupar espaço no layout
        this.element.style.position = 'static';
        this.element.style.transform = '';
        this.element.classList.remove('translate-x-0');
        this.element.classList.remove('fixed');
        this.element.classList.remove('hidden');
        console.log("🔧 Desktop: sidebar visível");
      } else {
        // Desktop: sidebar oculto - position fixed para não ocupar espaço
        this.element.style.position = 'fixed';
        this.element.style.transform = 'translateX(-100%)';
        this.element.classList.add('fixed');
        this.element.classList.remove('translate-x-0');
        this.element.classList.remove('hidden');
        console.log("🔧 Desktop: sidebar oculta");
      }
    } else {
      // Mobile: manter position fixed e aplicar transform
      this.element.style.position = 'fixed';
      this.element.classList.add('fixed');
      if (open) {
        this.element.style.transform = 'translateX(0) !important';
        this.element.classList.add('translate-x-0');
        console.log("🔧 Mobile: sidebar aberta");
      } else {
        this.element.style.transform = 'translateX(-100%) !important';
        this.element.classList.remove('translate-x-0');
        console.log("🔧 Mobile: sidebar fechada");
      }
    }

    // overlay
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.toggle('hidden', !open || isDesktop);
      console.log("🔧 Overlay hidden:", !open || isDesktop);
    }
  }
}
