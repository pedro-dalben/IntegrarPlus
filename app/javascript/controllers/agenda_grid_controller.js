import { Controller } from '@hotwired/stimulus';

window.handleSlotButtonClick = function (button, event) {
  event.preventDefault();
  event.stopPropagation();

  const datetime = button.getAttribute('data-datetime');
  const timeSlot = button.getAttribute('data-time-slot');

  if (!datetime || !timeSlot) return;

  const professionalSelect = document.querySelector('select[name="professional_id"]');
  const professionalId = professionalSelect?.value;

  if (!professionalId) {
    // eslint-disable-next-line no-alert
    alert('Por favor, selecione um profissional antes de escolher o horário.');
    return;
  }

  const previousButton = document.querySelector('.slot-selected');
  if (previousButton) {
    previousButton.classList.remove(
      'slot-selected',
      'bg-blue-500',
      'border-blue-600',
      'text-white'
    );
    previousButton.classList.add(
      'bg-green-100',
      'hover:bg-green-200',
      'border-green-300',
      'text-green-800'
    );
  }

  button.classList.remove(
    'bg-green-100',
    'hover:bg-green-200',
    'border-green-300',
    'text-green-800'
  );
  button.classList.add('slot-selected', 'bg-blue-500', 'border-blue-600', 'text-white');

  const dateObj = new Date(datetime);
  const year = dateObj.getFullYear();
  const month = String(dateObj.getMonth() + 1).padStart(2, '0');
  const day = String(dateObj.getDate()).padStart(2, '0');
  const dateString = `${year}-${month}-${day}`;
  const [timeString] = timeSlot.split(' - ');

  const dateInput = document.querySelector('[data-agenda-scheduler-target="dateSelect"]');
  const timeInput = document.querySelector('[data-agenda-scheduler-target="timeSelect"]');
  const datetimeSection = document.querySelector(
    '[data-agenda-scheduler-target="datetimeSection"]'
  );
  const previewSection = document.querySelector('[data-agenda-scheduler-target="previewSection"]');
  const submitButton = document.querySelector('[data-agenda-scheduler-target="submitButton"]');

  if (dateInput) dateInput.value = dateString;
  if (timeInput) timeInput.value = timeString;
  if (datetimeSection) datetimeSection.classList.remove('hidden');

  const scheduledDateTimeTarget = document.querySelector(
    '[data-agenda-scheduler-target="scheduledDateTime"]'
  );
  if (scheduledDateTimeTarget) {
    const formattedDate = new Date(dateString).toLocaleDateString('pt-BR');
    scheduledDateTimeTarget.textContent = `${formattedDate} às ${timeString}`;
  }

  if (previewSection) previewSection.classList.remove('hidden');
  if (submitButton) submitButton.disabled = false;
};

export default class extends Controller {
  connect() {
    this.boundHandleSlotClick = this.handleSlotClick.bind(this);
    document.addEventListener('click', this.boundHandleSlotClick);
  }

  disconnect() {
    if (this.boundHandleSlotClick) {
      document.removeEventListener('click', this.boundHandleSlotClick);
    }
  }

  handleSlotClick(event) {
    console.log('handleSlotClick called', event.target);
    const button = event.target.closest('.slot-button');
    console.log('Button found:', button);
    if (!button) return;

    event.preventDefault();
    event.stopPropagation();

    const datetime = button.getAttribute('data-datetime');
    const timeSlot = button.getAttribute('data-time-slot');

    console.log('Date and time:', { datetime, timeSlot });
    if (!datetime || !timeSlot) return;

    const professionalSelect = document.querySelector('select[name="professional_id"]');
    const professionalId = professionalSelect?.value;

    if (!professionalId) {
      // eslint-disable-next-line no-alert
      alert('Por favor, selecione um profissional antes de escolher o horário.');
      return;
    }

    const previousButton = document.querySelector('.slot-selected');
    if (previousButton) {
      previousButton.classList.remove(
        'slot-selected',
        'bg-blue-500',
        'border-blue-600',
        'text-white'
      );
      previousButton.classList.add(
        'bg-green-100',
        'hover:bg-green-200',
        'border-green-300',
        'text-green-800'
      );
    }

    button.classList.remove(
      'bg-green-100',
      'hover:bg-green-200',
      'border-green-300',
      'text-green-800'
    );
    button.classList.add('slot-selected', 'bg-blue-500', 'border-blue-600', 'text-white');

    const dateObj = new Date(datetime);
    const year = dateObj.getFullYear();
    const month = String(dateObj.getMonth() + 1).padStart(2, '0');
    const day = String(dateObj.getDate()).padStart(2, '0');
    const dateString = `${year}-${month}-${day}`;
    const [timeString] = timeSlot.split(' - ');

    const dateInput = document.querySelector('[data-agenda-scheduler-target="dateSelect"]');
    const timeInput = document.querySelector('[data-agenda-scheduler-target="timeSelect"]');
    const datetimeSection = document.querySelector(
      '[data-agenda-scheduler-target="datetimeSection"]'
    );
    const previewSection = document.querySelector(
      '[data-agenda-scheduler-target="previewSection"]'
    );
    const submitButton = document.querySelector('[data-agenda-scheduler-target="submitButton"]');

    if (dateInput) dateInput.value = dateString;
    if (timeInput) timeInput.value = timeString;
    if (datetimeSection) datetimeSection.classList.remove('hidden');

    const scheduledDateTimeTarget = document.querySelector(
      '[data-agenda-scheduler-target="scheduledDateTime"]'
    );
    if (scheduledDateTimeTarget) {
      const formattedDate = new Date(dateString).toLocaleDateString('pt-BR');
      scheduledDateTimeTarget.textContent = `${formattedDate} às ${timeString}`;
    }

    if (previewSection) previewSection.classList.remove('hidden');
    if (submitButton) submitButton.disabled = false;
  }

  hideGrid() {
    const gridSection = document.getElementById('agenda-grid-section');
    if (gridSection) {
      gridSection.classList.add('hidden');
    }
  }
}
