import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['panel', 'button', 'indicator', 'arrow'];

  connect() {
    this.closeDropdown = this.closeDropdown.bind(this);

    if (this.hasPanelTarget) {
      const hasActiveItem = !!this.panelTarget.querySelector('.menu-item.active');
      const startsOpen = hasActiveItem || !this.panelTarget.classList.contains('hidden');

      if (startsOpen) {
        this.panelTarget.classList.remove('hidden');
        if (this.hasButtonTarget) {
          this.buttonTarget.setAttribute('aria-expanded', 'true');
        } else {
          this.element.setAttribute('aria-expanded', 'true');
        }
        if (this.hasArrowTarget) {
          this.arrowTarget.classList.add('rotate-180');
        }
      } else {
        this.panelTarget.classList.add('hidden');
        if (this.hasButtonTarget) {
          this.buttonTarget.setAttribute('aria-expanded', 'false');
        } else {
          this.element.setAttribute('aria-expanded', 'false');
        }
        if (this.hasArrowTarget) {
          this.arrowTarget.classList.remove('rotate-180');
        }
      }
    }

    this._onTurboLoad = () => this.closeDropdown();
    document.addEventListener('turbo:load', this._onTurboLoad);
  }

  toggle(event) {
    event.preventDefault();
    if (!this.hasPanelTarget) return;
    const isOpen = this.panelTarget.classList.contains('hidden');

    if (isOpen) {
      this.openDropdown();
    } else {
      this.closeDropdown();
    }
  }

  openDropdown() {
    if (!this.hasPanelTarget) return;
    this.panelTarget.classList.remove('hidden');

    // Atualiza aria-expanded
    if (this.hasButtonTarget) {
      this.buttonTarget.setAttribute('aria-expanded', 'true');
    } else {
      this.element.setAttribute('aria-expanded', 'true');
    }

    // Esconde indicador se existir
    if (this.hasIndicatorTarget) {
      this.indicatorTarget.classList.add('hidden');
    }

    // Rotaciona seta se existir
    if (this.hasArrowTarget) {
      this.arrowTarget.classList.add('rotate-180');
    }

    // Adiciona listener para click fora
    document.addEventListener('click', this.closeDropdown);

    document.addEventListener('turbo:render', this.closeDropdown);
  }

  closeDropdown(event) {
    if (!this.hasPanelTarget) return;
    // Se foi um click dentro do dropdown, não fechar
    if (event && this.element.contains(event.target)) {
      return;
    }

    // Se foi um click no botão do dropdown, não fechar (deixar o toggle lidar)
    if (event && this.hasButtonTarget && this.buttonTarget.contains(event.target)) {
      return;
    }

    this.panelTarget.classList.add('hidden');

    // Atualiza aria-expanded
    if (this.hasButtonTarget) {
      this.buttonTarget.setAttribute('aria-expanded', 'false');
    } else {
      this.element.setAttribute('aria-expanded', 'false');
    }

    // Remove rotação da seta se existir
    if (this.hasArrowTarget) {
      this.arrowTarget.classList.remove('rotate-180');
    }

    // Remove listeners
    document.removeEventListener('click', this.closeDropdown);
    document.removeEventListener('turbo:render', this.closeDropdown);
  }

  handleKeydown(event) {
    if (event.key === 'Enter' || event.key === ' ') {
      event.preventDefault();
      this.toggle(event);
    } else if (event.key === 'Escape') {
      this.closeDropdown();
    }
  }

  disconnect() {
    document.removeEventListener('click', this.closeDropdown);
    document.removeEventListener('turbo:render', this.closeDropdown);
    if (this._onTurboLoad) {
      document.removeEventListener('turbo:load', this._onTurboLoad);
      this._onTurboLoad = null;
    }
  }
}
