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

// Alpine.js será configurado no tailadmin-pro/index.js

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
