// To see this message, add the following to the `<head>` section in your
// views/layouts/application.html.erb
//
//    <%= vite_client_tag %>
//    <%= vite_javascript_tag 'application' %>
console.log('Vite ⚡️ Rails')

// If using a TypeScript entrypoint file:
//     <%= vite_typescript_tag 'application' %>
//
// If you want to use .jsx or .tsx, add the extension:
//     <%= vite_javascript_tag 'application.jsx' %>

console.log('Visit the guide for more information: ', 'https://vite-ruby.netlify.app/guide/rails')

// Stimulus application é iniciado em ../javascript/application
// (remove o uso de stimulus-vite-helpers)

// Example: Load Rails libraries in Vite.
//
// import * as Turbo from '@hotwired/turbo'
// Turbo.start()
//
// import ActiveStorage from '@rails/activestorage'
// ActiveStorage.start()
//
// // Import all channels.
// const channels = import.meta.globEager('./**/*_channel.js')

// Example: Import a stylesheet in app/frontend/index.css
// import '~/index.css'
import "../styles/application.css";
import "../javascript/application";

// Alpine.js - DEVE vir ANTES de outras libs que mexem no DOM
import Alpine from 'alpinejs';
import persist from '@alpinejs/persist';
import 'alpine-turbo-drive-adapter'; // 👈 mantém Alpine vivo em navegação Turbo

Alpine.plugin(persist);
window.Alpine = Alpine;

// Store global para TailAdmin (deve ser definido antes do Alpine.start())
Alpine.store('tailadmin', {
  page: 'dashboard',
  selected: 'Dashboard',
  sidebarToggle: false,
  
  setPage(pageName) {
    this.page = pageName;
  },
  
  setSelected(menuName) {
    this.selected = menuName;
  },
  
  toggleSidebar() {
    this.sidebarToggle = !this.sidebarToggle;
  }
});

// Configuração do Alpine.js para variáveis globais do TailAdmin
Alpine.data("tailadmin", () => ({
  // Variáveis de navegação
  page: 'dashboard',
  selected: 'Dashboard',
  sidebarToggle: false,
  
  // Métodos de navegação
  setPage(pageName) {
    this.page = pageName;
  },
  
  setSelected(menuName) {
    this.selected = menuName;
  },
  
  toggleSidebar() {
    this.sidebarToggle = !this.sidebarToggle;
  },
  
  // Inicialização
  init() {
    // Detectar página atual baseada na URL
    const path = window.location.pathname;
    if (path.includes('dashboard')) {
      this.page = 'dashboard';
      this.selected = 'Dashboard';
    } else if (path.includes('professionals')) {
      this.page = 'professionals';
      this.selected = 'Professionals';
    } else if (path.includes('specialities')) {
      this.page = 'specialities';
      this.selected = 'Specialities';
    } else if (path.includes('contract-types')) {
      this.page = 'contractTypes';
      this.selected = 'Contract Types';
    } else if (path.includes('tailadmin-demo')) {
      this.page = 'tailadminDemo';
      this.selected = 'TailAdmin Demo';
    }
  }
}));

// Componente dropdown original do TailAdmin
Alpine.data("dropdown", () => ({
  open: false,
  toggle() {
    this.open = !this.open;
    if (this.open) this.position();
  },
  position() {
    this.$nextTick(() => {
      const button = this.$el;
      const dropdown = this.$refs.dropdown;
      const rect = button.getBoundingClientRect();

      dropdown.style.position = "fixed";
      dropdown.style.top = `${rect.bottom + window.scrollY}px`;
      dropdown.style.right = `${window.innerWidth - rect.right}px`;
      dropdown.style.zIndex = "999";

      const dropdownRect = dropdown.getBoundingClientRect();
      if (dropdownRect.bottom > window.innerHeight) {
        dropdown.style.top = `${rect.top + window.scrollY - dropdownRect.height}px`;
      }
    });
  },
  init() {
    this.$watch("open", (value) => {
      if (value) this.position();
    });
  },
}));

// Componente para menu dropdown
Alpine.data("menuDropdown", () => ({
  open: false,
  toggle() {
    this.open = !this.open;
  }
}));

// Componente para sidebar
Alpine.data("sidebar", () => ({
  sidebarToggle: false,
  toggleSidebar() {
    this.sidebarToggle = !this.sidebarToggle;
  }
}));

// Evita multi-start em HMR (Vite)
if (!window.__ALPINE_STARTED__) {
  Alpine.start();
  window.__ALPINE_STARTED__ = true;
}

// Re-inicialização segura para Turbo / renders parciais
const reinitAll = () => {
  console.log('🔄 Re-inicializando componentes após navegação...');
  
  // Re-varrer o DOM para componentes Alpine injetados depois do start
  if (window.Alpine && typeof window.Alpine.initTree === "function") {
    window.Alpine.initTree(document.body);
  }

  // Reinit Preline (se presente)
  if (window.HSStaticMethods && typeof window.HSStaticMethods.autoInit === "function") {
    window.HSStaticMethods.autoInit();
  }

  // Reinit os componentes do TailAdmin Pro
  if (window.TailAdminPro && typeof window.TailAdminPro.initializeComponents === "function") {
    window.TailAdminPro.initializeComponents();
  }
  
  console.log('✅ Re-inicialização concluída');
};

// Event listeners para re-inicialização
document.addEventListener("turbo:load", reinitAll);
document.addEventListener("turbo:render", reinitAll);
document.addEventListener("DOMContentLoaded", reinitAll);

// Agora sim importe libs que dependem do DOM já "alpinizado"
import "../javascript/tailadmin-pro";
import "preline";
import "bootstrap-icons/font/bootstrap-icons.css";
import "flatpickr/dist/flatpickr.css";
import "tom-select/dist/css/tom-select.css";
import "dropzone/dist/dropzone.css";
import "swiper/css";
import "swiper/css/navigation";
import "swiper/css/pagination";
import "prismjs/themes/prism.css";

// TailAdmin Pro specific JavaScript functionality
document.addEventListener("DOMContentLoaded", function () {
  const searchInput = document.getElementById("search-input");
  const searchButton = document.getElementById("search-button");

  if (searchInput && searchButton) {
    // Function to focus the search input
    function focusSearchInput() {
      searchInput.focus();
    }

    // Add click event listener to the search button
    searchButton.addEventListener("click", focusSearchInput);

    // Add keyboard event listener for Cmd+K (Mac) or Ctrl+K (Windows/Linux)
    document.addEventListener("keydown", function (event) {
      if ((event.metaKey || event.ctrlKey) && event.key === "k") {
        event.preventDefault(); // Prevent the default browser behavior
        focusSearchInput();
      }
    });

    // Add keyboard event listener for "/" key
    document.addEventListener("keydown", function (event) {
      if (event.key === "/" && document.activeElement !== searchInput) {
        event.preventDefault(); // Prevent the "/" character from being typed
        focusSearchInput();
      }
    });
  }
});

document.addEventListener("turbo:load", () => {
  if (window.HSStaticMethods && typeof window.HSStaticMethods.autoInit === "function") {
    window.HSStaticMethods.autoInit()
  }
})
