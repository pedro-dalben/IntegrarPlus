// ----------------------------
// Vite + estilos base
// ----------------------------
import "../styles/application.css";
import "../../styles/prism.css";
import "../../styles/tailadmin-pro.css";

import "flatpickr/dist/flatpickr.min.css";
import "tom-select/dist/css/tom-select.css";
import "dropzone/dist/dropzone.css";
import "swiper/css";
import "swiper/css/navigation";
import "swiper/css/pagination";
import "bootstrap-icons/font/bootstrap-icons.css";

// ----------------------------
// Alpine primeiro (antes de qq módulo que o use)
// ----------------------------
import Alpine from "alpinejs";
import persist from "@alpinejs/persist";
import "alpine-turbo-drive-adapter"; // precisa estar carregado antes do .start()

Alpine.plugin(persist);
window.Alpine = Alpine;

// Start apenas uma vez (evita duplicar em HMR/Turbo)
if (!window.__ALPINE_STARTED__) {
  Alpine.start();
  window.__ALPINE_STARTED__ = true;
}

// ----------------------------
// Sua app Stimulus/Hotwire (se houver)
// ----------------------------
import "../javascript/application";

// ----------------------------
// TailAdmin: importar depois de Alpine exposto
// (o index.js do TailAdmin **não** deve chamar Alpine.start())
// ----------------------------
import { bootTailadmin } from "../javascript/tailadmin-pro/index";

// ----------------------------
// Bibliotecas que não dependem de Alpine global no import time
// (se alguma depender, mova para dentro do bootTailadmin)
// ----------------------------
import "preline";           // HSStaticMethods.autoInit disponível em window
import "../javascript/tailadmin-pro"; // caso tenha side-effects necessários DEPOIS de Alpine exposto

// ----------------------------
// Reinit seguro para Turbo / renders parciais
// (agora Alpine já existe no window)
// ----------------------------
const reinitAll = () => {
  console.log("🔄 Re-inicializando componentes após navegação...");

  // Revarrer o DOM para componentes Alpine injetados após o start
  if (window.Alpine && typeof window.Alpine.initTree === "function") {
    window.Alpine.initTree(document.body);
  }

  // Reinit Preline (se presente)
  if (window.HSStaticMethods && typeof window.HSStaticMethods.autoInit === "function") {
    window.HSStaticMethods.autoInit();
  }

  // Se você tiver um namespace global do TailAdmin (opcional)
  if (window.TailAdminPro && typeof window.TailAdminPro.initializeComponents === "function") {
    window.TailAdminPro.initializeComponents();
  }

  console.log("✅ Re-inicialização concluída");
};

// ----------------------------
// Boot inicial + eventos Turbo
// ----------------------------
function hardBoot() {
  bootTailadmin();
  reinitAll();
}

// 1) Hard load
if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", hardBoot);
} else {
  hardBoot();
}

// 2) Soft loads via Turbo
document.addEventListener("turbo:load", () => {
  bootTailadmin();
  reinitAll();
});

document.addEventListener("turbo:render", reinitAll);

// ----------------------------
// TailAdmin JS adicional (não crítico)
// ----------------------------
document.addEventListener("DOMContentLoaded", function () {
  const searchInput = document.getElementById("search-input");
  const searchButton = document.getElementById("search-button");
  if (!searchInput || !searchButton) return;

  const focusSearchInput = () => searchInput.focus();

  searchButton.addEventListener("click", focusSearchInput);

  document.addEventListener("keydown", function (event) {
    if ((event.metaKey || event.ctrlKey) && event.key === "k") {
      event.preventDefault();
      focusSearchInput();
    }
  });

  document.addEventListener("keydown", function (event) {
    if (event.key === "/" && document.activeElement !== searchInput) {
      event.preventDefault();
      focusSearchInput();
    }
  });
});

// Re-aplicar Preline a cada navegação Turbo
document.addEventListener("turbo:load", () => {
  if (window.HSStaticMethods && typeof window.HSStaticMethods.autoInit === "function") {
    window.HSStaticMethods.autoInit();
  }
});
