import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = [
    'professionalsCount',
    'professionalsList',
    'workingHoursSummary',
    'previewContainer',
  ];

  connect() {
    this.updateReviewData();
  }

  updateReviewData() {
    this.updateProfessionalsCount();
    this.updateProfessionalsList();
    this.updateWorkingHoursSummary();
  }

  updateProfessionalsCount() {
    const selectedProfessionals = document.querySelectorAll(
      'input[name="agenda[professional_ids][]"]'
    );
    const count = selectedProfessionals.length;

    if (this.hasProfessionalsCountTarget) {
      this.professionalsCountTarget.textContent = count;
    }
  }

  updateProfessionalsList() {
    const selectedProfessionals = document.querySelectorAll('input[name*="professional_ids"]');

    if (selectedProfessionals.length === 0) {
      if (this.hasProfessionalsListTarget) {
        this.professionalsListTarget.innerHTML = `
          <div class="text-sm text-gray-500">Nenhum profissional selecionado</div>
        `;
      }
      return;
    }

    let html = '';
    selectedProfessionals.forEach(input => {
      const professionalId = input.value;
      const name = input.dataset.professionalName || '';
      const specialties = input.dataset.professionalSpecialties || '';

      html += `
        <div class="flex items-center justify-between py-2 px-3 bg-gray-50 rounded-lg">
          <div>
            <div class="text-sm font-medium text-gray-900">${name}</div>
            <div class="text-sm text-gray-500">${specialties}</div>
          </div>
          <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
            Ativo
          </span>
        </div>
      `;
    });

    if (this.hasProfessionalsListTarget) {
      this.professionalsListTarget.innerHTML = html;
    }
  }

  updateWorkingHoursSummary() {
    const workingHoursInput = document.querySelector('input[name*="working_hours"]');
    let summary = 'Não configurado';

    if (workingHoursInput && workingHoursInput.value) {
      try {
        const workingHours = JSON.parse(workingHoursInput.value);
        const weekdays = workingHours.weekdays || [];

        if (weekdays.length > 0) {
          const dayNames = weekdays.map(day => {
            const dayName = ['Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado'][
              day.wday
            ];
            const periods = day.periods.map(p => `${p.start}-${p.end}`).join(', ');
            return `${dayName}: ${periods}`;
          });
          summary = dayNames.join(' | ');
        }
      } catch (e) {}
    }

    if (this.hasWorkingHoursSummaryTarget) {
      this.workingHoursSummaryTarget.textContent = summary;
    }
  }

  generatePreview() {
    if (this.hasPreviewContainerTarget) {
      this.previewContainerTarget.innerHTML = `
        <div class="text-center text-gray-500 py-8">
          <svg class="w-8 h-8 mx-auto text-gray-400 mb-2 animate-spin" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
          </svg>
          <p class="text-sm">Gerando preview...</p>
        </div>
      `;
    }

    // Simulate AJAX call
    setTimeout(() => {
      this.showPreviewData();
    }, 1000);
  }

  showPreviewData() {
    if (this.hasPreviewContainerTarget) {
      this.previewContainerTarget.innerHTML = `
        <div class="space-y-3">
          <div class="text-sm font-medium text-gray-900">Dr. João Silva</div>
          <div class="space-y-1">
            <div class="text-xs text-gray-600">Seg 15/01 - 08:00-09:00</div>
            <div class="text-xs text-gray-600">Seg 15/01 - 09:10-10:10</div>
            <div class="text-xs text-gray-600">Seg 15/01 - 10:20-11:20</div>
          </div>
          
          <div class="text-sm font-medium text-gray-900 mt-4">Dra. Maria Santos</div>
          <div class="space-y-1">
            <div class="text-xs text-gray-600">Seg 15/01 - 08:00-09:00</div>
            <div class="text-xs text-gray-600">Seg 15/01 - 09:10-10:10</div>
          </div>
        </div>
      `;
    }
  }
}
