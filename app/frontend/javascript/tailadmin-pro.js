// TailAdmin Pro - Importação completa do JavaScript original
// Baseado no vendor/tailadmin-pro/js/index.js

console.log('TailAdmin Pro JS carregando...');

// CSS imports (já importados no application.js)
// import "jsvectormap/dist/jsvectormap.min.css";
// import "flatpickr/dist/flatpickr.min.css";
// import "dropzone/dist/dropzone.css";

// Alpine.js já está configurado no application.js
// import persist from "@alpinejs/persist";
// import Alpine from "alpinejs";

// Imports principais
import flatpickr from "flatpickr";
import Dropzone from "dropzone";

console.log('Flatpickr e Dropzone importados');

// Charts específicos do TailAdmin (importação simplificada)
try {
  import("../../../vendor/tailadmin-pro/js/components/charts/chart-01.js");
  import("../../../vendor/tailadmin-pro/js/components/charts/chart-02.js");
  import("../../../vendor/tailadmin-pro/js/components/charts/chart-03.js");
  import("../../../vendor/tailadmin-pro/js/components/charts/chart-04.js");
  import("../../../vendor/tailadmin-pro/js/components/charts/chart-05.js");
  console.log('Charts carregados com sucesso');
} catch (error) {
  console.error('Erro ao carregar charts:', error);
}

// Outros componentes (importação simplificada)
try {
  import("../../../vendor/tailadmin-pro/js/components/map-01.js");
  import("../../../vendor/tailadmin-pro/js/components/trending-stocks.js");
  import("../../../vendor/tailadmin-pro/js/components/calendar-init.js");
  import("../../../vendor/tailadmin-pro/js/components/task-drag.js");
  import("../../../vendor/tailadmin-pro/js/components/image-resize.js");
  import("../../../vendor/tailadmin-pro/js/components/prism.js");
  console.log('Componentes carregados com sucesso');
} catch (error) {
  console.error('Erro ao carregar componentes:', error);
}

// Inicializar flatpickr (configuração completa do TailAdmin)
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

// Inicializar Dropzone
const dropzoneArea = document.querySelectorAll("#demo-upload");
if (dropzoneArea.length) {
  new Dropzone("#demo-upload", { url: "/file/post" });
}

// Função para inicializar todos os componentes quando o DOM estiver pronto
function initializeTailAdminComponents() {
  // Inicializar charts
  if (typeof chart01 === 'function') chart01();
  if (typeof chart02 === 'function') chart02();
  if (typeof chart03 === 'function') chart03();
  if (typeof chart04 === 'function') chart04();
  if (typeof chart05 === 'function') chart05();
  if (typeof chart06 === 'function') chart06();
  if (typeof chart07 === 'function') chart07();
  if (typeof chart08 === 'function') chart08();
  if (typeof chart09 === 'function') chart09();
  if (typeof chart10 === 'function') chart10();
  if (typeof chart11 === 'function') chart11();
  if (typeof chart12 === 'function') chart12();
  if (typeof chart13 === 'function') chart13();
  if (typeof chart14 === 'function') chart14();
  if (typeof chart15 === 'function') chart15();
  if (typeof chart16 === 'function') chart16();
  if (typeof chart17 === 'function') chart17();
  if (typeof chart18 === 'function') chart18();
  if (typeof chart19 === 'function') chart19();
  if (typeof chart20 === 'function') chart20();
  if (typeof chart21 === 'function') chart21();
  if (typeof chart22 === 'function') chart22();
  if (typeof chart23 === 'function') chart23();
  if (typeof chart24 === 'function') chart24();
  
  // Inicializar map
  if (typeof map01 === 'function') map01();

  // Atualizar ano atual
  const year = document.getElementById("year");
  if (year) {
    year.textContent = new Date().getFullYear();
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

// Event listeners
document.addEventListener("DOMContentLoaded", () => {
  initializeTailAdminComponents();
  initializeOTP();
  initializeCopy();
});

// Para compatibilidade com Turbo
document.addEventListener("turbo:load", () => {
  initializeTailAdminComponents();
  initializeOTP();
  initializeCopy();
});

// Exportar para uso em outros arquivos
window.TailAdminPro = {
  initializeComponents: initializeTailAdminComponents,
  initializeOTP,
  initializeCopy,
  flatpickr,
  Dropzone
};

console.log('TailAdmin Pro JS carregado completamente!');
