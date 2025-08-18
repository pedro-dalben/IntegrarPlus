// TailAdmin Pro - Importação completa e otimizada
// Integração com Vite e Rails

console.log('🚀 TailAdmin Pro JS carregando...');

// Imports principais
import flatpickr from "flatpickr";
import Dropzone from "dropzone";

// Charts do TailAdmin Pro
import chart01 from "../../../vendor/tailadmin-pro/js/components/charts/chart-01.js";
import chart02 from "../../../vendor/tailadmin-pro/js/components/charts/chart-02.js";
import chart03 from "../../../vendor/tailadmin-pro/js/components/charts/chart-03.js";
import chart04 from "../../../vendor/tailadmin-pro/js/components/charts/chart-04.js";
import chart05 from "../../../vendor/tailadmin-pro/js/components/charts/chart-05.js";
import chart06 from "../../../vendor/tailadmin-pro/js/components/charts/chart-06.js";
import chart07 from "../../../vendor/tailadmin-pro/js/components/charts/chart-07.js";
import chart08 from "../../../vendor/tailadmin-pro/js/components/charts/chart-08.js";
import chart09 from "../../../vendor/tailadmin-pro/js/components/charts/chart-09.js";
import chart10 from "../../../vendor/tailadmin-pro/js/components/charts/chart-10.js";
import chart11 from "../../../vendor/tailadmin-pro/js/components/charts/chart-11.js";
import chart12 from "../../../vendor/tailadmin-pro/js/components/charts/chart-12.js";
import chart13 from "../../../vendor/tailadmin-pro/js/components/charts/chart-13.js";
import chart14 from "../../../vendor/tailadmin-pro/js/components/charts/chart-14.js";
import chart15 from "../../../vendor/tailadmin-pro/js/components/charts/chart-15.js";
import chart16 from "../../../vendor/tailadmin-pro/js/components/charts/chart-16.js";
import chart17 from "../../../vendor/tailadmin-pro/js/components/charts/chart-17.js";
import chart18 from "../../../vendor/tailadmin-pro/js/components/charts/chart-18.js";
import chart19 from "../../../vendor/tailadmin-pro/js/components/charts/chart-19.js";
import chart20 from "../../../vendor/tailadmin-pro/js/components/charts/chart-20.js";
import chart21 from "../../../vendor/tailadmin-pro/js/components/charts/chart-21.js";
import chart22 from "../../../vendor/tailadmin-pro/js/components/charts/chart-22.js";
import chart23 from "../../../vendor/tailadmin-pro/js/components/charts/chart-23.js";
import chart24 from "../../../vendor/tailadmin-pro/js/components/charts/chart-24.js";

// Outros componentes
import map01 from "../../../vendor/tailadmin-pro/js/components/map-01.js";
import "../../../vendor/tailadmin-pro/js/components/carousels/carousel-01.js";
import "../../../vendor/tailadmin-pro/js/components/carousels/carousel-02.js";
import "../../../vendor/tailadmin-pro/js/components/carousels/carousel-03.js";
import "../../../vendor/tailadmin-pro/js/components/carousels/carousel-04.js";
import "../../../vendor/tailadmin-pro/js/components/trending-stocks.js";
import "../../../vendor/tailadmin-pro/js/components/calendar-init.js";
import "../../../vendor/tailadmin-pro/js/components/task-drag.js";
import "../../../vendor/tailadmin-pro/js/components/image-resize.js";
import "../../../vendor/tailadmin-pro/js/components/prism.js";

console.log('✅ Todos os componentes importados');

// Alpine.js já está configurado no application.js

// Inicializar flatpickr
function initializeFlatpickr() {
  flatpickr(".datepicker", {
    mode: "range",
    static: true,
    monthSelectorType: "static",
    dateFormat: "M j, Y",
    defaultDate: [new Date().setDate(new Date().getDate() - 6), new Date()],
    prevArrow:
      '<svg class="stroke-current" width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M15.25 6L9 12.25L15.25 18.5" stroke="" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>',
    nextArrow:
      '<svg class="stroke-current" width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M8.75 19L15 12.75L8.75 6.5" stroke="" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>',
    onReady: (selectedDates, dateStr, instance) => {
      instance.element.value = dateStr.replace("to", "-");
      const customClass = instance.element.getAttribute("data-class");
      if (customClass) {
        instance.calendarContainer.classList.add(customClass);
      }
    },
    onChange: (selectedDates, dateStr, instance) => {
      instance.element.value = dateStr.replace("to", "-");
    },
  });

  flatpickr(".datepickerTwo", {
    static: true,
    monthSelectorType: "static",
    dateFormat: "M j, Y",
    prevArrow:
      '<svg class="stroke-current" width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M15.25 6L9 12.25L15.25 18.5" stroke="" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>',
    nextArrow:
      '<svg class="stroke-current" width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M8.75 19L15 12.75L8.75 6.5" stroke="" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>',
    onReady: (selectedDates, dateStr, instance) => {
      instance.element.value = dateStr.replace("to", "-");
      const customClass = instance.element.getAttribute("data-class");
      if (customClass) {
        instance.calendarContainer.classList.add(customClass);
      }
    },
    onChange: (selectedDates, dateStr, instance) => {
      instance.element.value = dateStr.replace("to", "-");
    },
  });
}

// Inicializar Dropzone
function initializeDropzone() {
  const dropzoneArea = document.querySelectorAll("#demo-upload");
  if (dropzoneArea.length) {
    new Dropzone("#demo-upload", { url: "/file/post" });
  }
}

// Inicializar charts
function initializeCharts() {
  const charts = [
    chart01, chart02, chart03, chart04, chart05, chart06, chart07, chart08,
    chart09, chart10, chart11, chart12, chart13, chart14, chart15, chart16,
    chart17, chart18, chart19, chart20, chart21, chart22, chart23, chart24
  ];

  charts.forEach((chart, index) => {
    if (typeof chart === 'function') {
      try {
        chart();
      } catch (error) {
        console.warn(`Erro ao inicializar chart ${index + 1}:`, error);
      }
    }
  });

  if (typeof map01 === 'function') {
    try {
      map01();
    } catch (error) {
      console.warn('Erro ao inicializar map:', error);
    }
  }
}

// OTP functionality
function initializeOTP() {
  const otpInputs = document.querySelectorAll("#otp-container .otp-input");

  otpInputs.forEach((input, index) => {
    input.addEventListener("input", (e) => {
      const value = e.target.value;

      if (value && index < otpInputs.length - 1) {
        otpInputs[index + 1].focus();
      }

      if (index === otpInputs.length - 1 && value) {
        e.target.blur();
      }
    });

    input.addEventListener("keydown", (e) => {
      if (e.key === "Backspace") {
        if (!e.target.value && index > 0) {
          otpInputs[index - 1].focus();
        }
      } else if (e.key === "ArrowLeft" && index > 0) {
        otpInputs[index - 1].focus();
      } else if (e.key === "ArrowRight" && index < otpInputs.length - 1) {
        otpInputs[index + 1].focus();
      }
    });

    input.addEventListener("paste", (e) => {
      e.preventDefault();

      const pasteData = e.clipboardData
        .getData("text")
        .slice(0, otpInputs.length);
      otpInputs.forEach((input, i) => {
        input.value = pasteData[i] || "";
      });

      const lastFilledIndex = pasteData.length - 1;
      if (lastFilledIndex >= 0 && lastFilledIndex < otpInputs.length) {
        otpInputs[lastFilledIndex].focus();
      }
    });
  });
}

// Copy functionality
function initializeCopy() {
  const copyInput = document.getElementById("copy-input");
  if (copyInput) {
    const copyButton = document.getElementById("copy-button");
    const copyText = document.getElementById("copy-text");
    const websiteInput = document.getElementById("website-input");

    if (copyButton && copyText && websiteInput) {
      copyButton.addEventListener("click", () => {
        navigator.clipboard.writeText(websiteInput.value).then(() => {
          copyText.textContent = "Copied";

          setTimeout(() => {
            copyText.textContent = "Copy";
          }, 2000);
        });
      });
    }
  }
}

// Search functionality
function initializeSearch() {
  const searchInput = document.getElementById("search-input");
  const searchButton = document.getElementById("search-button");

  if (searchInput && searchButton) {
    function focusSearchInput() {
      searchInput.focus();
    }

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
  }
}

// Função principal de inicialização
function initializeTailAdminComponents() {
  console.log('🔄 Inicializando componentes TailAdmin...');
  
  initializeFlatpickr();
  initializeDropzone();
  initializeCharts();
  initializeOTP();
  initializeCopy();
  initializeSearch();

  // Atualizar ano atual
  const year = document.getElementById("year");
  if (year) {
    year.textContent = new Date().getFullYear();
  }

  console.log('✅ TailAdmin Pro inicializado com sucesso!');
}

// Event listeners para diferentes cenários
document.addEventListener("DOMContentLoaded", initializeTailAdminComponents);
document.addEventListener("turbo:load", initializeTailAdminComponents);
document.addEventListener("turbo:render", initializeTailAdminComponents);

// Para compatibilidade com navegação SPA
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializeTailAdminComponents);
} else {
  initializeTailAdminComponents();
}

// Exportar para uso global
window.TailAdminPro = {
  initializeComponents: initializeTailAdminComponents,
  initializeFlatpickr,
  initializeDropzone,
  initializeCharts,
  initializeOTP,
  initializeCopy,
  initializeSearch,
  flatpickr,
  Dropzone
};

console.log('🎉 TailAdmin Pro JS carregado completamente!');
