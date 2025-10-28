import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['startTime', 'endTime', 'result'];

  async checkAvailability() {
    const startTime = this.startTimeTarget.value;
    const endTime = this.endTimeTarget.value;

    if (!startTime || !endTime) {
      this.showError('Por favor, preencha ambos os horários');
      return;
    }

    const startDateTime = new Date(startTime);
    const endDateTime = new Date(endTime);

    if (endDateTime <= startDateTime) {
      this.showError('A data de fim deve ser posterior à data de início');
      return;
    }

    this.showLoading();

    try {
      const response = await fetch(
        `/professional_agendas/${this.getProfessionalId()}/availability`,
        {
          method: 'GET',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
          },
          body: JSON.stringify({
            start_time: startDateTime.toISOString(),
            end_time: endDateTime.toISOString(),
          }),
        }
      );

      if (response.ok) {
        const data = await response.json();
        this.showResult(data);
      } else {
        throw new Error('Erro ao verificar disponibilidade');
      }
    } catch (error) {
      this.showError('Erro ao verificar disponibilidade. Tente novamente.');
    }
  }

  getProfessionalId() {
    const path = window.location.pathname;
    const match = path.match(/\/professional_agendas\/(\d+)/);
    return match ? match[1] : null;
  }

  showLoading() {
    this.resultTarget.innerHTML = `
      <div class="flex items-center justify-center p-4">
        <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-primary"></div>
        <span class="ml-2 text-sm text-gray-600 dark:text-gray-400">Verificando disponibilidade...</span>
      </div>
    `;
  }

  showResult(data) {
    const { available, conflicting_events } = data;

    if (available) {
      this.resultTarget.innerHTML = `
        <div class="rounded-md bg-green-50 p-4 dark:bg-green-900/20">
          <div class="flex">
            <div class="flex-shrink-0">
              <svg class="h-5 w-5 text-green-400" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
              </svg>
            </div>
            <div class="ml-3">
              <h3 class="text-sm font-medium text-green-800 dark:text-green-200">
                Horário Disponível
              </h3>
              <p class="mt-1 text-sm text-green-700 dark:text-green-300">
                O profissional está disponível no horário solicitado.
              </p>
            </div>
          </div>
        </div>
      `;
    } else {
      let conflictsHtml = '';

      if (conflicting_events && conflicting_events.length > 0) {
        conflictsHtml = `
          <div class="mt-3">
            <h4 class="text-sm font-medium text-red-800 dark:text-red-200 mb-2">
              Eventos Conflitantes:
            </h4>
            <div class="space-y-2">
              ${conflicting_events
                .map(
                  event => `
                <div class="flex items-center gap-2 text-sm text-red-700 dark:text-red-300">
                  <div class="h-2 w-2 rounded-full bg-red-500"></div>
                  <span>${event.title} - ${this.formatTime(event.start_time)} às ${this.formatTime(event.end_time)}</span>
                </div>
              `
                )
                .join('')}
            </div>
          </div>
        `;
      }

      this.resultTarget.innerHTML = `
        <div class="rounded-md bg-red-50 p-4 dark:bg-red-900/20">
          <div class="flex">
            <div class="flex-shrink-0">
              <svg class="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
              </svg>
            </div>
            <div class="ml-3">
              <h3 class="text-sm font-medium text-red-800 dark:text-red-200">
                Horário Indisponível
              </h3>
              <p class="mt-1 text-sm text-red-700 dark:text-red-300">
                O profissional não está disponível no horário solicitado.
              </p>
              ${conflictsHtml}
            </div>
          </div>
        </div>
      `;
    }
  }

  showError(message) {
    this.resultTarget.innerHTML = `
      <div class="rounded-md bg-red-50 p-4 dark:bg-red-900/20">
        <div class="flex">
          <div class="flex-shrink-0">
            <svg class="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
            </svg>
          </div>
          <div class="ml-3">
            <h3 class="text-sm font-medium text-red-800 dark:text-red-200">
              Erro
            </h3>
            <p class="mt-1 text-sm text-red-700 dark:text-red-300">
              ${message}
            </p>
          </div>
        </div>
      </div>
    `;
  }

  formatTime(dateTimeString) {
    const date = new Date(dateTimeString);
    return date.toLocaleString('pt-BR', {
      day: '2-digit',
      month: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
    });
  }
}
