import flatpickr from "flatpickr";
import Dropzone from "dropzone";
Dropzone.autoDiscover = false;

import chart01 from "./components/charts/chart-01";
import chart02 from "./components/charts/chart-02";
import chart03 from "./components/charts/chart-03";
import chart04 from "./components/charts/chart-04";
import chart05 from "./components/charts/chart-05";
import chart06 from "./components/charts/chart-06";
import chart07 from "./components/charts/chart-07";
import chart08 from "./components/charts/chart-08";
import chart09 from "./components/charts/chart-09";
import chart10 from "./components/charts/chart-10";
import chart11 from "./components/charts/chart-11";
import chart12 from "./components/charts/chart-12";
import chart13 from "./components/charts/chart-13";
import chart14 from "./components/charts/chart-14";
import chart15 from "./components/charts/chart-15";
import chart16 from "./components/charts/chart-16";
import chart17 from "./components/charts/chart-17";
import chart18 from "./components/charts/chart-18";
import chart19 from "./components/charts/chart-19";
import chart20 from "./components/charts/chart-20";
import chart21 from "./components/charts/chart-21";
import chart22 from "./components/charts/chart-22";
import chart23 from "./components/charts/chart-23";
import chart24 from "./components/charts/chart-24";
import map01 from "./components/map-01";
import carousel01 from "./components/carousels/carousel-01";
import carousel02 from "./components/carousels/carousel-02";
import carousel03 from "./components/carousels/carousel-03";
import carousel04 from "./components/carousels/carousel-04";
import trendingStocks from "./components/trending-stocks.js";
import calendarInit from "./components/calendar-init.js";
import taskDrag from "./components/task-drag.js";
import imageResize from "./components/image-resize";

function registerAlpineOnce() {
  if (!window.__ALPINE_COMPONENTS__) window.__ALPINE_COMPONENTS__ = {};
  const A = window.Alpine;

  if (!window.__ALPINE_COMPONENTS__.dropdown) {
    A.data("dropdown", () => ({
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
          const dr = dropdown.getBoundingClientRect();
          if (dr.bottom > window.innerHeight) {
            dropdown.style.top = `${rect.top + window.scrollY - dr.height}px`;
          }
        });
      },
      init() {
        this.$watch("open", (v) => v && this.position());
      },
    }));
    window.__ALPINE_COMPONENTS__.dropdown = true;
  }
}

function initFlatpickr() {
  document.querySelectorAll(".datepicker").forEach((el) => {
    if (el._flatpickr) el._flatpickr.destroy();
    flatpickr(el, {
      mode: "range",
      static: true,
      monthSelectorType: "static",
      dateFormat: "M j, Y",
      defaultDate: [new Date().setDate(new Date().getDate() - 6), new Date()],
      prevArrow:
        '<svg class="stroke-current" width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M15.25 6L9 12.25L15.25 18.5" stroke="" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>',
      nextArrow:
        '<svg class="stroke-current" width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M8.75 19L15 12.75L8.75 6.5" stroke="" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>',
      onReady: (_s, str, inst) => {
        inst.element.value = str.replace("to", "-");
        const customClass = inst.element.getAttribute("data-class");
        if (customClass) inst.calendarContainer.classList.add(customClass);
      },
      onChange: (_s, str, inst) => (inst.element.value = str.replace("to", "-")),
    });
  });

  document.querySelectorAll(".datepickerTwo").forEach((el) => {
    if (el._flatpickr) el._flatpickr.destroy();
    flatpickr(el, {
      static: true,
      monthSelectorType: "static",
      dateFormat: "M j, Y",
      prevArrow:
        '<svg class="stroke-current" width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M15.25 6L9 12.25L15.25 18.5" stroke="" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>',
      nextArrow:
        '<svg class="stroke-current" width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M8.75 19L15 12.75L8.75 6.5" stroke="" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>',
      onReady: (_s, str, inst) => {
        inst.element.value = str.replace("to", "-");
        const customClass = inst.element.getAttribute("data-class");
        if (customClass) inst.calendarContainer.classList.add(customClass);
      },
      onChange: (_s, str, inst) => (inst.element.value = str.replace("to", "-")),
    });
  });
}

function initDropzone() {
  document.querySelectorAll("#demo-upload").forEach((el) => {
    if (el.__dropzone) return;
    el.__dropzone = new Dropzone(el, { url: "/file/post" });
  });
}

function initChartsAndMisc() {
  const safe = (fn) => { try { fn?.(); } catch (_) {} };
  safe(chart01);
  safe(chart02);
  safe(chart03);
  safe(chart04);
  safe(chart05);
  safe(chart06);
  safe(chart07);
  safe(chart08);
  safe(chart09);
  safe(chart10);
  safe(chart11);
  safe(chart12);
  safe(chart13);
  safe(chart14);
  safe(chart15);
  safe(chart16);
  safe(chart17);
  safe(chart18);
  safe(chart19);
  safe(chart20);
  safe(chart21);
  safe(chart22);
  safe(chart23);
  safe(chart24);
  safe(map01);
  safe(carousel01);
  safe(carousel02);
  safe(carousel03);
  safe(carousel04);
  safe(trendingStocks);
  safe(calendarInit);
  safe(taskDrag);
  safe(imageResize);

  const year = document.getElementById("year");
  if (year) year.textContent = new Date().getFullYear();
}

function initOtp() {
  const otpInputs = document.querySelectorAll("#otp-container .otp-input");
  if (!otpInputs.length) return;

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

function initCopy() {
  const copyInput = document.getElementById("copy-input");
  if (!copyInput) return;

  const copyButton = document.getElementById("copy-button");
  const copyText = document.getElementById("copy-text");
  const websiteInput = document.getElementById("website-input");

  copyButton.addEventListener("click", () => {
    navigator.clipboard.writeText(websiteInput.value).then(() => {
      copyText.textContent = "Copied";
      setTimeout(() => {
        copyText.textContent = "Copy";
      }, 2000);
    });
  });
}

function initSearch() {
  const searchInput = document.getElementById("search-input");
  const searchButton = document.getElementById("search-button");
  if (!searchInput || !searchButton) return;

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

export function bootTailadmin() {
  registerAlpineOnce();
  initFlatpickr();
  initDropzone();
  initChartsAndMisc();
  initOtp();
  initCopy();
  initSearch();
}
