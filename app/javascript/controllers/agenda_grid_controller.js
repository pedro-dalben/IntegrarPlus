import { Controller } from '@hotwired/stimulus';

window.handleSlotButtonClick = async function handleSlotButtonClick(button, event) {
  event.preventDefault();
  event.stopPropagation();

  const datetime = button.getAttribute('data-datetime');
  const timeSlot = button.getAttribute('data-time-slot');

  if (!datetime || !timeSlot) return;

  button.disabled = true;
  button.classList.add('opacity-50', 'cursor-wait');

  const professionalSelect = document.querySelector('select[name="professional_id"]');
  let professionalId = button.getAttribute('data-professional-id');
  let professionalName = button.getAttribute('data-professional-name');

  if (!professionalName) {
    const section = button.closest('[data-professional-name]');
    professionalName = section ? section.getAttribute('data-professional-name') : '';
  }

  if (!professionalId) {
    professionalId = professionalSelect?.value;
  }

  if (!professionalId) {
    button.disabled = false;
    button.classList.remove('opacity-50', 'cursor-wait');
    if (window.Alert) {
      window.Alert.warning('Atenção', 'Por favor, selecione um profissional antes de escolher o horário.');
    } else {
      alert('Por favor, selecione um profissional antes de escolher o horário.');
    }
    return;
  }

  if (professionalId === 'all') {
    button.disabled = false;
    button.classList.remove('opacity-50', 'cursor-wait');
    if (window.Alert) {
      window.Alert.warning('Atenção', 'Para agendar, selecione um profissional específico.');
    } else {
      alert('Para agendar, selecione um profissional específico.');
    }
    return;
  }

  const agendasDataElement = document.querySelector('[data-agenda-scheduler-target="agendasData"]');
  if (!agendasDataElement) {
    button.disabled = false;
    button.classList.remove('opacity-50', 'cursor-wait');
    console.error('Dados das agendas não encontrados');
    return;
  }

  const agendasData = JSON.parse(agendasDataElement.textContent);
  const agendaSelect = document.querySelector('[data-agenda-scheduler-target="agendaSelect"]');
  const agendaId = agendaSelect?.value;
  const agenda = agendasData.find((a) => a.id == agendaId);

  if (!agenda || !agenda.slot_duration_minutes) {
    button.disabled = false;
    button.classList.remove('opacity-50', 'cursor-wait');
    console.error('Agenda não encontrada ou sem duração configurada');
    return;
  }

  const durationMinutes = agenda.slot_duration_minutes;
  const slotInterval = 30;
  const slotsNeeded = Math.ceil(durationMinutes / slotInterval);

  const portalIntakeIdElement = document.querySelector('[data-agenda-scheduler-portal-intake-id-value]');
  const portalIntakeId =
    portalIntakeIdElement?.getAttribute('data-agenda-scheduler-portal-intake-id-value') ||
    portalIntakeIdElement?.dataset?.agendaSchedulerPortalIntakeIdValue;

  const professionalIdStr = professionalId?.toString();

  if (portalIntakeId) {
    try {
      const formElement = document.querySelector('[data-controller*="agenda-scheduler"]');
      if (formElement && window.Stimulus) {
        const controller = window.Stimulus.getControllerForElementAndIdentifier(formElement, 'agenda-scheduler');
        if (controller && controller.checkSlotAvailability) {
          const availability = await controller.checkSlotAvailability(datetime, agendaId, professionalId);
          if (!availability.available) {
            button.disabled = false;
            button.classList.remove('opacity-50', 'cursor-wait');
            const conflictsMsg = availability.conflicts.map((c) => c.message).join('<br>');
            if (window.Alert) {
              window.Alert.error(
                'Horário Indisponível',
                `Este horário não está mais disponível.<br><br>${conflictsMsg || 'Conflito detectado.'}`,
                { html: true }
              );
            } else {
              alert(`Este horário não está mais disponível.\n\n${conflictsMsg.replace(/<br>/g, '\n') || 'Conflito detectado.'}`);
            }
            return;
          }
        }
      }
    } catch (error) {
      console.error('Erro ao verificar disponibilidade:', error);
    }
  }

  const previousSelectedButtons = document.querySelectorAll('.slot-selected');
  previousSelectedButtons.forEach((prevButton) => {
    prevButton.style.transition = 'all 0.3s ease';
    prevButton.classList.remove('slot-selected', 'bg-blue-500', 'border-blue-600', 'text-white', 'scale-105');
    prevButton.classList.add('bg-green-100', 'hover:bg-green-200', 'border-green-300', 'text-green-800');
    prevButton.textContent = 'Livre';
    setTimeout(() => {
      prevButton.style.transition = '';
    }, 300);
  });

  const selectedButtons = [];
  const startTime = new Date(datetime);

  for (let i = 0; i < slotsNeeded; i += 1) {
    const slotTime = new Date(startTime);
    slotTime.setMinutes(slotTime.getMinutes() + i * slotInterval);

    const slotTimeString = slotTime.toTimeString().slice(0, 5);
    const slotDateString = slotTime.toISOString().slice(0, 10);

    const allButtons = document.querySelectorAll('.slot-button[data-datetime]');
    const matchingButton = Array.from(allButtons).find((btn) => {
      const btnDateTime = new Date(btn.getAttribute('data-datetime'));
      const btnDateString = btnDateTime.toISOString().slice(0, 10);
      const btnTimeString = btnDateTime.toTimeString().slice(0, 5);
      const btnProfessionalId =
        btn.getAttribute('data-professional-id') || btn.dataset.professionalId || professionalSelect?.value || '';
      const sameProfessional = professionalIdStr ? btnProfessionalId === professionalIdStr : true;
      return sameProfessional && btnDateString === slotDateString && btnTimeString === slotTimeString;
    });

    if (matchingButton) {
      matchingButton.style.transition = 'all 0.3s ease';
      matchingButton.classList.remove('bg-green-100', 'hover:bg-green-200', 'border-green-300', 'text-green-800');
      matchingButton.classList.add('slot-selected', 'bg-blue-500', 'border-blue-600', 'text-white', 'scale-105');
      matchingButton.textContent = i === 0 ? 'Início' : i === slotsNeeded - 1 ? 'Fim' : '';
      setTimeout(() => {
        matchingButton.classList.remove('scale-105');
        matchingButton.style.transition = '';
      }, 300);
      if (professionalIdStr) {
        matchingButton.dataset.professionalId = professionalIdStr;
      }
      if (professionalName) {
        matchingButton.dataset.professionalName = professionalName;
      }
      selectedButtons.push(matchingButton);
    }
  }

  const endTime = new Date(startTime);
  endTime.setMinutes(endTime.getMinutes() + durationMinutes);

  const dateObj = new Date(datetime);
  const year = dateObj.getFullYear();
  const month = String(dateObj.getMonth() + 1).padStart(2, '0');
  const day = String(dateObj.getDate()).padStart(2, '0');
  const dateString = `${year}-${month}-${day}`;
  const [timeString] = timeSlot.split(' - ');

  const endTimeString = endTime.toTimeString().slice(0, 5);
  const endDateString = endTime.toISOString().slice(0, 10);

  const dateInput = document.querySelector('[data-agenda-scheduler-target="dateSelect"]');
  const timeInput = document.querySelector('[data-agenda-scheduler-target="timeSelect"]');
  const endTimeInput = document.querySelector('[data-agenda-scheduler-target="endTimeSelect"]');
  const timeLabel = document.querySelector('[data-agenda-scheduler-target="timeLabel"]');
  const timeHelpText = document.querySelector('[data-agenda-scheduler-target="timeHelpText"]');
  const datetimeSection = document.querySelector('[data-agenda-scheduler-target="datetimeSection"]');
  const previewSection = document.querySelector('[data-agenda-scheduler-target="previewSection"]');
  const submitButton = document.querySelector('[data-agenda-scheduler-target="submitButton"]');
  const durationTarget = document.querySelector('[data-agenda-scheduler-target="appointmentDuration"]');
  const professionalNameTarget = document.querySelector('[data-agenda-scheduler-target="professionalName"]');
  const scheduledDateTimeTarget = document.querySelector('[data-agenda-scheduler-target="scheduledDateTime"]');

  if (dateInput) dateInput.value = dateString;
  if (timeInput) timeInput.value = timeString;
  if (endTimeInput) endTimeInput.value = `${endDateString} ${endTimeString}`;
  if (timeLabel) timeLabel.textContent = 'Horário Selecionado para o Atendimento';
  if (timeHelpText) timeHelpText.textContent = `Período do atendimento: ${timeString} até ${endTimeString}`;
  if (datetimeSection) datetimeSection.classList.remove('hidden');

  if (professionalNameTarget && professionalName) {
    professionalNameTarget.textContent = professionalName;
  }

  if (scheduledDateTimeTarget) {
    const formattedDate = new Date(dateString).toLocaleDateString('pt-BR');
    const formattedEndDate = new Date(endDateString).toLocaleDateString('pt-BR');
    const professionalText = professionalName ? ` (${professionalName})` : '';
    if (formattedDate === formattedEndDate) {
      scheduledDateTimeTarget.textContent = `${formattedDate} das ${timeString} às ${endTimeString}${professionalText}`;
    } else {
      scheduledDateTimeTarget.textContent = `${formattedDate} ${timeString} até ${formattedEndDate} ${endTimeString}${professionalText}`;
    }
  }

  if (durationTarget) {
    const hours = Math.floor(durationMinutes / 60);
    const minutes = durationMinutes % 60;
    if (hours > 0 && minutes > 0) {
      durationTarget.textContent = `${hours}h${minutes > 0 ? `${minutes}min` : ''}`;
    } else if (hours > 0) {
      durationTarget.textContent = `${hours}h`;
    } else {
      durationTarget.textContent = `${minutes}min`;
    }
  }

  if (previewSection) previewSection.classList.remove('hidden');
  if (submitButton) submitButton.disabled = false;

  selectedButtons.forEach((btn) => {
    btn.disabled = false;
    btn.classList.remove('opacity-50', 'cursor-wait');
  });

  button.disabled = false;
  button.classList.remove('opacity-50', 'cursor-wait');
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
    const button = event.target.closest('.slot-button');
    if (!button) return;

    window.handleSlotButtonClick(button, event);
  }

  hideGrid() {
    const gridSection = document.getElementById('agenda-grid-section');
    if (gridSection) {
      gridSection.classList.add('hidden');
    }
  }
}
import { Controller } from '@hotwired/stimulus';

window.handleSlotButtonClick = function (button, event) {
  event.preventDefault();
  event.stopPropagation();

  const datetime = button.getAttribute('data-datetime');
  const timeSlot = button.getAttribute('data-time-slot');

  if (!datetime || !timeSlot) return;

  const professionalSelect = document.querySelector('select[name="professional_id"]');
  const professionalId = professionalSelect?.value;

  if (!professionalId || professionalId === 'all') {
    if (window.Alert) {
      window.Alert.warning('Atenção', 'Selecione um profissional específico antes de escolher o horário.');
    } else {
      alert('Selecione um profissional específico antes de escolher o horário.');
    }
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

    if (!professionalId || professionalId === 'all') {
      // eslint-disable-next-line no-alert
      alert('Selecione um profissional específico antes de escolher o horário.');
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
