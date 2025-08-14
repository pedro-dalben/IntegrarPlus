// TailAdmin Pro - Componentes essenciais
// Importa apenas o que realmente precisamos

// Alpine.js já está configurado no application.js

// FullCalendar - Calendário
import { Calendar } from '@fullcalendar/core';
import dayGridPlugin from '@fullcalendar/daygrid';
import timeGridPlugin from '@fullcalendar/timegrid';
import interactionPlugin from '@fullcalendar/interaction';
import listPlugin from '@fullcalendar/list';

// ApexCharts - Gráficos
import ApexCharts from 'apexcharts';

// Swiper - Carrosséis
import Swiper from 'swiper';
import { Navigation, Pagination, Autoplay } from 'swiper/modules';

// Dropzone - Upload de arquivos
import Dropzone from 'dropzone';

// Prism.js - Syntax highlighting
import Prism from 'prismjs';

// JSVectorMap - Mapas
import 'jsvectormap';
import 'jsvectormap/dist/maps/world';

// Flatpickr - Date picker (já configurado)
// Tom Select - Select avançado (já configurado)

// Inicializar componentes quando necessário
document.addEventListener('turbo:load', () => {
  // Inicializar FullCalendar se houver elementos com data-calendar
  const calendarElements = document.querySelectorAll('[data-calendar]');
  calendarElements.forEach(element => {
    new Calendar(element, {
      plugins: [dayGridPlugin, timeGridPlugin, interactionPlugin, listPlugin],
      headerToolbar: {
        left: 'prev,next today',
        center: 'title',
        right: 'dayGridMonth,timeGridWeek,timeGridDay,listWeek'
      },
      initialView: 'dayGridMonth',
      editable: true,
      selectable: true,
      selectMirror: true,
      dayMaxEvents: true,
      weekends: true
    });
  });

  // Inicializar ApexCharts se houver elementos com data-chart
  const chartElements = document.querySelectorAll('[data-chart]');
  chartElements.forEach(element => {
    const chartType = element.dataset.chart;
    const chartData = JSON.parse(element.dataset.chartData || '{}');
    
    const options = {
      chart: {
        type: chartType,
        height: 350
      },
      series: chartData.series || [],
      xaxis: chartData.xaxis || {},
      ...chartData.options
    };
    
    new ApexCharts(element, options).render();
  });

  // Inicializar Swiper se houver elementos com data-swiper
  const swiperElements = document.querySelectorAll('[data-swiper]');
  swiperElements.forEach(element => {
    new Swiper(element, {
      modules: [Navigation, Pagination, Autoplay],
      slidesPerView: 1,
      spaceBetween: 30,
      navigation: {
        nextEl: '.swiper-button-next',
        prevEl: '.swiper-button-prev',
      },
      pagination: {
        el: '.swiper-pagination',
        clickable: true,
      },
      autoplay: {
        delay: 5000,
        disableOnInteraction: false,
      },
    });
  });

  // Inicializar Dropzone se houver elementos com data-dropzone
  const dropzoneElements = document.querySelectorAll('[data-dropzone]');
  dropzoneElements.forEach(element => {
    new Dropzone(element, {
      url: element.dataset.url || '/upload',
      acceptedFiles: element.dataset.acceptedFiles || 'image/*',
      maxFiles: parseInt(element.dataset.maxFiles) || 10,
      maxFilesize: parseInt(element.dataset.maxFilesize) || 5,
    });
  });

  // Inicializar Prism.js para syntax highlighting
  Prism.highlightAll();
});

// Exportar para uso em outros arquivos
window.TailAdminPro = {
  Calendar,
  ApexCharts,
  Swiper,
  Dropzone,
  Prism
};
