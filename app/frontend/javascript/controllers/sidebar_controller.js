import { Controller } from "@hotwired/stimulus";

const K = { SIDEBAR: "ui:sidebarOpen" };

export default class extends Controller {
  static targets = ["overlay"];

    connect() {
    // estado inicial baseado no tamanho da tela
    const isDesktop = window.innerWidth >= 1280;
    const savedState = localStorage.getItem(K.SIDEBAR) === "true";

    // Em desktop: sempre aberta, em mobile: fechada inicialmente
    const shouldBeOpen = isDesktop ? true : false;

    // Aplicar estado inicial com inline styles
    if (isDesktop) {
      this.element.style.transform = '';
    } else {
      this.element.style.transform = 'translateX(-100%)';
    }

    this.apply(shouldBeOpen);

    // Debounce para evitar eventos duplos
    this._debounceTimeout = null;
    this._sync = (e) => {
      // Clear previous timeout
      if (this._debounceTimeout) {
        clearTimeout(this._debounceTimeout);
      }

      // Debounce the apply call
      this._debounceTimeout = setTimeout(() => {
        this.apply(!!e.detail?.open);
      }, 10);
    };
    window.addEventListener("ui:sidebar", this._sync);

    // Ao navegar, feche em mobile
    document.addEventListener("turbo:load", () => {
      if (window.innerWidth < 1280) this.apply(false);
    });

    // Fechar sidebar em mobile ao clicar em links
    this._linkClickHandler = (e) => {
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
      const currentState = localStorage.getItem(K.SIDEBAR) === "true";
      const shouldBeOpen = isDesktop ? true : currentState;
      this.apply(shouldBeOpen);
    };

    window.addEventListener("resize", this._resizeHandler);
  }

  disconnect() {
    window.removeEventListener("ui:sidebar", this._sync);
    if (this._resizeHandler) {
      window.removeEventListener("resize", this._resizeHandler);
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

  apply(open) {
    localStorage.setItem(K.SIDEBAR, String(open));
    
    // Em desktop: sempre visível, em mobile: controlar com transform
    const isDesktop = window.innerWidth >= 1280;
    
    if (isDesktop) {
      // Desktop: remover transform
      this.element.style.transform = '';
      this.element.classList.remove("translate-x-0");
    } else {
      // Mobile: aplicar transform inline
      if (open) {
        this.element.style.transform = 'translateX(0)';
        this.element.classList.add("translate-x-0");
      } else {
        this.element.style.transform = 'translateX(-100%)';
        this.element.classList.remove("translate-x-0");
      }
    }
    
    // overlay
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.toggle("hidden", !open || isDesktop);
    }
  }

  toggleGroup(event) {
    // Verificar se o clique foi no botão do grupo ou em um link dentro do dropdown
    const clickedElement = event.target.closest('a');
    
    // Se clicou em um link dentro do dropdown, permitir navegação
    if (clickedElement && clickedElement.closest('[data-sidebar-dropdown]')) {
      return; // Permitir navegação normal
    }
    
    // Se clicou no botão do grupo, prevenir navegação e toggle
    if (clickedElement && clickedElement.getAttribute('href') === '#') {
      event.preventDefault();
      event.stopPropagation();
    }
    
    const name = event.params.name;
    const group = this.element.querySelector(`[data-sidebar-group="${name}"]`);
    const dropdown = group?.querySelector('[data-sidebar-dropdown]');
    const button = group?.querySelector('[data-sidebar-target="groupButton"]');
    
    if (dropdown && button) {
      const isExpanded = button.getAttribute('aria-expanded') === 'true';
      const newExpanded = !isExpanded;
      
      button.setAttribute('aria-expanded', String(newExpanded));
      dropdown.classList.toggle('hidden', !newExpanded);
    }
  }

  handleKeydown(event) {
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      this.toggleGroup(event);
    }
  }
}
