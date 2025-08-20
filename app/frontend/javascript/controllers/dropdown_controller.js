import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["panel", "button", "indicator", "arrow"];

  connect() {
    this.closeDropdown = this.closeDropdown.bind(this);
  }

  toggle(event) {
    event.preventDefault();
    const isOpen = this.panelTarget.classList.contains("hidden");
    
    if (isOpen) {
      this.openDropdown();
    } else {
      this.closeDropdown();
    }
  }

  openDropdown() {
    this.panelTarget.classList.remove("hidden");
    
    // Posiciona o dropdown dinamicamente
    this.positionDropdown();
    
    // Atualiza aria-expanded
    if (this.hasButtonTarget) {
      this.buttonTarget.setAttribute("aria-expanded", "true");
    } else {
      this.element.setAttribute("aria-expanded", "true");
    }
    
    // Esconde indicador se existir
    if (this.hasIndicatorTarget) {
      this.indicatorTarget.classList.add("hidden");
    }
    
    // Rotaciona seta se existir
    if (this.hasArrowTarget) {
      this.arrowTarget.classList.add("rotate-180");
    }
    
    // Adiciona listener para click fora
    document.addEventListener("click", this.closeDropdown);
    
    // Fecha em turbo:load
    document.addEventListener("turbo:load", this.closeDropdown);
  }

  closeDropdown(event) {
    // Se foi um click dentro do dropdown, não fechar
    if (event && this.element.contains(event.target)) {
      return;
    }
    
    // Se foi um click no botão do dropdown, não fechar (deixar o toggle lidar)
    if (event && this.hasButtonTarget && this.buttonTarget.contains(event.target)) {
      return;
    }
    
    this.panelTarget.classList.add("hidden");
    
    // Atualiza aria-expanded
    if (this.hasButtonTarget) {
      this.buttonTarget.setAttribute("aria-expanded", "false");
    } else {
      this.element.setAttribute("aria-expanded", "false");
    }
    
    // Remove rotação da seta se existir
    if (this.hasArrowTarget) {
      this.arrowTarget.classList.remove("rotate-180");
    }
    
    // Remove listeners
    document.removeEventListener("click", this.closeDropdown);
    document.removeEventListener("turbo:load", this.closeDropdown);
  }

  handleKeydown(event) {
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      this.toggle(event);
    } else if (event.key === "Escape") {
      this.closeDropdown();
    }
  }

  disconnect() {
    document.removeEventListener("click", this.closeDropdown);
    document.removeEventListener("turbo:load", this.closeDropdown);
  }

  positionDropdown() {
    const button = this.hasButtonTarget ? this.buttonTarget : this.element.querySelector('button');
    if (!button) return;

    const buttonRect = button.getBoundingClientRect();
    const dropdownRect = this.panelTarget.getBoundingClientRect();
    const viewportHeight = window.innerHeight;
    const viewportWidth = window.innerWidth;

    // Remove classes de posicionamento anteriores
    this.panelTarget.classList.remove('top-full', 'bottom-full', 'right-0', 'left-0');
    this.panelTarget.style.top = '';
    this.panelTarget.style.bottom = '';
    this.panelTarget.style.left = '';
    this.panelTarget.style.right = '';

    // Calcula se deve abrir para cima ou para baixo
    const spaceBelow = viewportHeight - buttonRect.bottom;
    const spaceAbove = buttonRect.top;
    const dropdownHeight = dropdownRect.height;

    // Posiciona verticalmente
    if (spaceBelow >= dropdownHeight || spaceBelow > spaceAbove) {
      // Abre para baixo
      this.panelTarget.classList.add('top-full');
      this.panelTarget.style.top = '0.25rem'; // mt-1
    } else {
      // Abre para cima
      this.panelTarget.classList.add('bottom-full');
      this.panelTarget.style.bottom = '0.25rem'; // mb-1
    }

    // Posiciona horizontalmente
    const spaceRight = viewportWidth - buttonRect.right;
    const spaceLeft = buttonRect.left;
    const dropdownWidth = dropdownRect.width;

    if (spaceRight >= dropdownWidth || spaceRight > spaceLeft) {
      // Alinha à direita
      this.panelTarget.classList.add('right-0');
    } else {
      // Alinha à esquerda
      this.panelTarget.classList.add('left-0');
    }
  }
}
