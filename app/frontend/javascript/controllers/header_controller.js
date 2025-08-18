import { Controller } from "@hotwired/stimulus";

const STORAGE_KEYS = {
  DARK: "ui:dark",
  SIDEBAR: "ui:sidebarOpen",
};

export default class extends Controller {
  static targets = ["searchInput"];

  connect() {
    // Aplica dark mode salvo
    const dark = localStorage.getItem(STORAGE_KEYS.DARK) === "true";
    this.applyDark(dark);

    // Fecha dropdowns ao navegar (se adicionar dropdowns depois)
    document.addEventListener("turbo:load", () => {
      // noop por enquanto; reservado p/ limpar estados se necessário
    });

    // Atalho / Cmd/Ctrl+K para busca
    document.addEventListener("keydown", (e) => {
      const k = e.key?.toLowerCase();
      if ((e.metaKey || e.ctrlKey) && k === "k") {
        e.preventDefault();
        this.focusSearch();
      }
      if (k === "/" && document.activeElement !== this.searchInputTarget) {
        e.preventDefault();
        this.focusSearch();
      }
    });
  }

  // Dark mode
  toggleDark() {
    const isDark = !document.documentElement.classList.contains("dark");
    this.applyDark(isDark);
    localStorage.setItem(STORAGE_KEYS.DARK, String(isDark));
  }

  applyDark(v) {
    document.documentElement.classList.toggle("dark", v);
  }

  // Sidebar
  toggleSidebar() {
    const next = !(localStorage.getItem(STORAGE_KEYS.SIDEBAR) === "true");
    localStorage.setItem(STORAGE_KEYS.SIDEBAR, String(next));
    // Emite evento global para qualquer interessando (ex.: sidebar_controller)
    window.dispatchEvent(new CustomEvent("ui:sidebar", { detail: { open: next } }));
  }

  focusSearch() {
    if (this.hasSearchInputTarget) this.searchInputTarget.focus();
  }
}
