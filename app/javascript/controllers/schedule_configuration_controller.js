import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['dayPeriods', 'hiddenInputs'];

  connect() {
    this.scheduleData = this.initializeScheduleData();
    this.updateHiddenInputs();
  }

  initializeScheduleData() {
    const data = {};

    for (let day = 0; day < 7; day++) {
      const dayElement = this.dayPeriodsTargets.find(el => el.dataset.day == day);
      if (dayElement) {
        const checkbox = dayElement.closest('.flex').querySelector('input[type="checkbox"]');
        data[day] = {
          enabled: checkbox.checked,
          periods: this.extractPeriodsFromDay(dayElement),
        };
      } else {
        data[day] = { enabled: false, periods: [] };
      }
    }

    return data;
  }

  extractPeriodsFromDay(dayElement) {
    const periods = [];
    const periodElements = dayElement.querySelectorAll('.flex.items-center.space-x-2');

    periodElements.forEach(element => {
      const startTime = element.querySelector('input[data-field="start_time"]')?.value;
      const endTime = element.querySelector('input[data-field="end_time"]')?.value;

      if (startTime && endTime) {
        periods.push({ start_time: startTime, end_time: endTime });
      }
    });

    return periods;
  }

  toggleDay(event) {
    const day = parseInt(event.target.dataset.day);
    const enabled = event.target.checked;

    this.scheduleData[day].enabled = enabled;

    if (enabled && this.scheduleData[day].periods.length === 0) {
      this.scheduleData[day].periods = [{ start_time: '08:00', end_time: '17:00' }];
    }

    this.updateDayDisplay(day);
    this.updateHiddenInputs();
  }

  addPeriod(event) {
    const day = parseInt(event.target.dataset.day);

    this.scheduleData[day].periods.push({ start_time: '08:00', end_time: '17:00' });
    this.updateDayDisplay(day);
    this.updateHiddenInputs();
  }

  removePeriod(event) {
    const day = parseInt(event.target.dataset.day);
    const period = parseInt(event.target.dataset.period);

    this.scheduleData[day].periods.splice(period, 1);
    this.updateDayDisplay(day);
    this.updateHiddenInputs();
  }

  updatePeriod(event) {
    const day = parseInt(event.target.dataset.day);
    const period = parseInt(event.target.dataset.period);
    const { field } = event.target.dataset;

    if (this.scheduleData[day].periods[period]) {
      this.scheduleData[day].periods[period][field] = event.target.value;
      this.updateHiddenInputs();
    }
  }

  updateDayDisplay(day) {
    const dayElement = this.dayPeriodsTargets.find(el => el.dataset.day == day);
    if (!dayElement) return;

    const checkbox = dayElement.closest('.flex').querySelector('input[type="checkbox"]');
    const enabled = checkbox.checked;

    if (enabled) {
      let html = '<div class="space-y-2">';

      this.scheduleData[day].periods.forEach((period, index) => {
        html += `
          <div class="flex items-center space-x-2">
            <input type="time"
                   class="px-3 py-1 border border-gray-300 rounded text-sm"
                   value="${period.start_time}"
                   data-action="change->schedule-configuration#updatePeriod"
                   data-day="${day}"
                   data-period="${index}"
                   data-field="start_time">
            <span class="text-gray-500">até</span>
            <input type="time"
                   class="px-3 py-1 border border-gray-300 rounded text-sm"
                   value="${period.end_time}"
                   data-action="change->schedule-configuration#updatePeriod"
                   data-day="${day}"
                   data-period="${index}"
                   data-field="end_time">
            <button type="button"
                    class="text-red-600 hover:text-red-800"
                    data-action="click->schedule-configuration#removePeriod"
                    data-day="${day}"
                    data-period="${index}">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
              </svg>
            </button>
          </div>
        `;
      });

      html += `
        <button type="button"
                class="text-blue-600 hover:text-blue-800 text-sm"
                data-action="click->schedule-configuration#addPeriod"
                data-day="${day}">
          + Adicionar período
        </button>
      </div>
      `;

      dayElement.innerHTML = html;
    } else {
      dayElement.innerHTML = '<div class="text-sm text-gray-500">Não disponível</div>';
    }
  }

  applyTemplate(event) {
    const { templateId } = event.target.dataset;

    const templates = {
      standard_business_hours: {
        1: {
          enabled: true,
          periods: [
            { start_time: '08:00', end_time: '12:00' },
            { start_time: '13:00', end_time: '17:00' },
          ],
        },
        2: {
          enabled: true,
          periods: [
            { start_time: '08:00', end_time: '12:00' },
            { start_time: '13:00', end_time: '17:00' },
          ],
        },
        3: {
          enabled: true,
          periods: [
            { start_time: '08:00', end_time: '12:00' },
            { start_time: '13:00', end_time: '17:00' },
          ],
        },
        4: {
          enabled: true,
          periods: [
            { start_time: '08:00', end_time: '12:00' },
            { start_time: '13:00', end_time: '17:00' },
          ],
        },
        5: {
          enabled: true,
          periods: [
            { start_time: '08:00', end_time: '12:00' },
            { start_time: '13:00', end_time: '17:00' },
          ],
        },
      },
      extended_hours: {
        1: { enabled: true, periods: [{ start_time: '07:00', end_time: '19:00' }] },
        2: { enabled: true, periods: [{ start_time: '07:00', end_time: '19:00' }] },
        3: { enabled: true, periods: [{ start_time: '07:00', end_time: '19:00' }] },
        4: { enabled: true, periods: [{ start_time: '07:00', end_time: '19:00' }] },
        5: { enabled: true, periods: [{ start_time: '07:00', end_time: '19:00' }] },
      },
      weekend_coverage: {
        1: { enabled: true, periods: [{ start_time: '08:00', end_time: '17:00' }] },
        2: { enabled: true, periods: [{ start_time: '08:00', end_time: '17:00' }] },
        3: { enabled: true, periods: [{ start_time: '08:00', end_time: '17:00' }] },
        4: { enabled: true, periods: [{ start_time: '08:00', end_time: '17:00' }] },
        5: { enabled: true, periods: [{ start_time: '08:00', end_time: '17:00' }] },
        6: { enabled: true, periods: [{ start_time: '09:00', end_time: '13:00' }] },
        0: { enabled: true, periods: [{ start_time: '09:00', end_time: '13:00' }] },
      },
    };

    if (templates[templateId]) {
      this.scheduleData = { ...this.scheduleData, ...templates[templateId] };

      for (let day = 0; day < 7; day++) {
        const checkbox = document.querySelector(`input[data-day="${day}"]`);
        if (checkbox) {
          checkbox.checked = this.scheduleData[day].enabled;
          this.updateDayDisplay(day);
        }
      }

      this.updateHiddenInputs();
    }
  }

  resetSchedule() {
    this.scheduleData = {};
    for (let day = 0; day < 7; day++) {
      this.scheduleData[day] = { enabled: false, periods: [] };
    }

    for (let day = 0; day < 7; day++) {
      const checkbox = document.querySelector(`input[data-day="${day}"]`);
      if (checkbox) {
        checkbox.checked = false;
        this.updateDayDisplay(day);
      }
    }

    this.updateHiddenInputs();
  }

  saveSchedule() {
    const formData = new FormData();

    Object.keys(this.scheduleData).forEach(day => {
      const dayData = this.scheduleData[day];
      formData.append(`schedule[${day}][enabled]`, dayData.enabled);

      dayData.periods.forEach((period, index) => {
        formData.append(`schedule[${day}][periods][${index}][start_time]`, period.start_time);
        formData.append(`schedule[${day}][periods][${index}][end_time]`, period.end_time);
      });
    });

    fetch('/admin/agendas/configure_schedule', {
      method: 'POST',
      body: formData,
      headers: {
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
      },
    })
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          this.showNotification('Horários salvos com sucesso!', 'success');
        } else {
          this.showNotification(`Erro ao salvar horários: ${data.error}`, 'error');
        }
      })
      .catch(error => {
        this.showNotification('Erro ao salvar horários', 'error');
      });
  }

  updateHiddenInputs() {
    this.hiddenInputsTarget.innerHTML = '';

    Object.keys(this.scheduleData).forEach(day => {
      const dayData = this.scheduleData[day];

      const enabledInput = document.createElement('input');
      enabledInput.type = 'hidden';
      enabledInput.name = `schedule[${day}][enabled]`;
      enabledInput.value = dayData.enabled;
      this.hiddenInputsTarget.appendChild(enabledInput);

      dayData.periods.forEach((period, index) => {
        const startInput = document.createElement('input');
        startInput.type = 'hidden';
        startInput.name = `schedule[${day}][periods][${index}][start_time]`;
        startInput.value = period.start_time;
        this.hiddenInputsTarget.appendChild(startInput);

        const endInput = document.createElement('input');
        endInput.type = 'hidden';
        endInput.name = `schedule[${day}][periods][${index}][end_time]`;
        endInput.value = period.end_time;
        this.hiddenInputsTarget.appendChild(endInput);
      });
    });
  }

  showNotification(message, type) {
    const notification = document.createElement('div');
    notification.className = `fixed top-4 right-4 p-4 rounded-lg text-white z-50 ${
      type === 'success' ? 'bg-green-600' : 'bg-red-600'
    }`;
    notification.textContent = message;

    document.body.appendChild(notification);

    setTimeout(() => {
      notification.remove();
    }, 3000);
  }
}
