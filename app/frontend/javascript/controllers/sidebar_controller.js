import { Controller } from "@hotwired/stimulus";

const STORAGE_KEYS = {
  SIDEBAR: "ui:sidebarOpen",
  GROUP:   "ui:sidebarGroup", // opcional
};

export default class extends Controller {
  static targets = ["panel", "groupList"]; // opcional

  connect() {
    // Estado inicial
    const open = localStorage.getItem(STORAGE_KEYS.SIDEBAR) === "true";
    this.applyOpen(open);

    // Ouvir eventos do header
    this._handler = (e) => this.applyOpen(!!e.detail?.open);
    window.addEventListener("ui:sidebar", this._handler);

    // Fechar ao navegar (mobile)
    document.addEventListener("turbo:load", () => {
      if (window.innerWidth < 1280) this.applyOpen(false);
    });
  }

  disconnect() {
    window.removeEventListener("ui:sidebar", this._handler);
  }

  // Clique fora
  outside(event) {
    if (window.innerWidth >= 1280) return; // XL ou maior: comportamento colapsado, não "drawer"
    if (!this.element.contains(event.target)) this.applyOpen(false);
  }

  // Aplicar estado visual
  applyOpen(open) {
    localStorage.setItem(STORAGE_KEYS.SIDEBAR, String(open));
    // Usa classes utilitárias conforme seu HTML original
    this.element.classList.toggle("-translate-x-full", !open);
    this.element.classList.toggle("translate-x-0", open);
    // Largura colapsada em XL: sua UI original usava 'xl:w-[90px]'
    this.element.classList.toggle("xl:w-[90px]", open);
  }

  // Dropdown de grupo (Dashboard/Profissionais/…)
  toggleGroup(event) {
    const name = event?.params?.name;
    const current = localStorage.getItem(STORAGE_KEYS.GROUP);
    const next = current === name ? "" : name;
    localStorage.setItem(STORAGE_KEYS.GROUP, next);
    this.updateGroups(next);
  }

  updateGroups(active) {
    // opcional: você pode marcar itens ativos via data-attrs/classe
    // ou simplesmente checar no HTML com helpers Rails.
  }
}
