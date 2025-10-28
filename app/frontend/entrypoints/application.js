// ----------------------------
// Vite + estilos base
// ----------------------------
import '../styles/application.css';
import '../styles/prism.css';
import '../styles/tailadmin-pro.css';

import 'flatpickr/dist/flatpickr.min.css';
import 'tom-select/dist/css/tom-select.css';
import 'dropzone/dist/dropzone.css';
import 'swiper/css';
import 'swiper/css/navigation';
import 'swiper/css/pagination';
import 'bootstrap-icons/font/bootstrap-icons.css';

// ----------------------------
// Sua app Stimulus/Hotwire
// ----------------------------
import '../javascript/application';

// ----------------------------
// TailAdmin: componentes específicos (se necessário)
// ----------------------------
import '../javascript/tailadmin-pro.js';

// ----------------------------
// Reinit seguro para Turbo / renders parciais
// ----------------------------
const reinitAll = () => {
  // Re-inicializar componentes TailAdmin se necessário
  if (window.TailAdminPro && typeof window.TailAdminPro.initializeComponents === 'function') {
    window.TailAdminPro.initializeComponents();
  }
};

// ----------------------------
// Boot inicial + eventos Turbo
// ----------------------------
function hardBoot() {
  reinitAll();
}

// 1) Hard load
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', hardBoot);
} else {
  hardBoot();
}

// 2) Soft loads via Turbo
document.addEventListener('turbo:load', () => {
  reinitAll();
});

document.addEventListener('turbo:render', reinitAll);

// ----------------------------
// TailAdmin JS adicional (não crítico)
// ----------------------------
document.addEventListener('DOMContentLoaded', () => {
  const searchInput = document.getElementById('search-input');
  const searchButton = document.getElementById('search-button');
  if (!searchInput || !searchButton) return;

  const focusSearchInput = () => searchInput.focus();
  searchButton.addEventListener('click', focusSearchInput);

  document.addEventListener('keydown', event => {
    if ((event.metaKey || event.ctrlKey) && event.key === 'k') {
      event.preventDefault();
      focusSearchInput();
    }
  });

  document.addEventListener('keydown', event => {
    if (event.key === '/' && document.activeElement !== searchInput) {
      event.preventDefault();
      focusSearchInput();
    }
  });
});
