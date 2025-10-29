import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = [
    'agendaSelect',
    'professionalSelect',
    'professionalSection',
    'datetimeSection',
    'dateSelect',
    'timeSelect',
    'previewSection',
    'submitButton',
    'beneficiaryName',
    'agendaName',
    'professionalName',
    'scheduledDateTime',
    'agendasData',
  ];

  static values = {
    portalIntakeId: Number,
  };

  connect() {
    this.agendas = this.parseAgendasData();
  }

  parseAgendasData() {
    try {
      const dataElement = this.agendasDataTarget;
      if (dataElement) {
        return JSON.parse(dataElement.textContent);
      }
    } catch (error) {
      console.error('Erro ao carregar dados das agendas:', error);
    }
    return [];
  }

  onAgendaChange() {
    const agendaId = this.agendaSelectTarget.value;

    if (agendaId) {
      const agenda = this.agendas.find(a => a.id == agendaId);
      if (agenda) {
        if (agenda.professionals && agenda.professionals.length > 0) {
          this.populateProfessionals(agenda.professionals);
          this.showSection(this.professionalSectionTarget);
          this.updatePreview('agenda', agenda.name);
          this.hideAgendaGrid();
        } else {
          // eslint-disable-next-line no-alert
          alert(
            'Esta agenda não possui profissionais cadastrados. Por favor, adicione profissionais à agenda primeiro.'
          );
          this.agendaSelectTarget.value = '';
          this.hideAllSections();
          this.clearPreview();
          this.hideAgendaGrid();
        }
      }
    } else {
      this.hideAllSections();
      this.clearPreview();
      this.hideAgendaGrid();
    }
  }

  onProfessionalChange() {
    const professionalId = this.professionalSelectTarget.value;

    if (professionalId) {
      if (professionalId === 'all') {
        this.updatePreview('professional', 'Todos os Profissionais');
        const agendaId = this.agendaSelectTarget.value;
        if (agendaId) {
          this.showAgendaGrid(agendaId);
        }
      } else {
        const professional = this.getSelectedProfessional();
        if (professional) {
          this.updatePreview('professional', professional.name);
          const agendaId = this.agendaSelectTarget.value;
          if (agendaId) {
            this.showAgendaGrid(agendaId);
          }
        }
      }
    } else {
      this.hideSectionsAfter('professional');
      this.clearPreview();
      this.hideAgendaGrid();
    }
  }

  onDateTimeSelected(date, time) {
    if (date && time) {
      this.dateSelectTarget.value = date;
      this.timeSelectTarget.value = time;
      this.showSection(this.datetimeSectionTarget);
      this.updatePreview('datetime', `${this.formatDate(date)} às ${time}`);
    }
  }

  populateProfessionals(professionals) {
    const select = this.professionalSelectTarget;
    select.innerHTML = '<option value="">Selecione um profissional</option>';

    if (professionals.length > 1) {
      const allOption = document.createElement('option');
      allOption.value = 'all';
      allOption.textContent = 'Todos os Profissionais';
      select.appendChild(allOption);
    }

    professionals.forEach(professional => {
      const option = document.createElement('option');
      option.value = professional.id;
      option.textContent = professional.name;
      select.appendChild(option);
    });
  }

  getSelectedAgenda() {
    const agendaId = this.agendaSelectTarget.value;
    return this.agendas.find(a => a.id == agendaId);
  }

  getSelectedProfessional() {
    const professionalId = this.professionalSelectTarget.value;
    if (professionalId === 'all') {
      return { id: 'all', name: 'Todos os Profissionais' };
    }
    const agenda = this.getSelectedAgenda();
    if (agenda) {
      return agenda.professionals.find(p => p.id == professionalId);
    }
    return null;
  }

  showSection(section) {
    section.classList.remove('hidden');
  }

  hideSection(section) {
    section.classList.add('hidden');
  }

  hideAllSections() {
    this.hideSection(this.professionalSectionTarget);
    this.hideSection(this.datetimeSectionTarget);
    this.hideSection(this.previewSectionTarget);
    this.disableSubmit();
  }

  hideSectionsAfter(sectionName) {
    switch (sectionName) {
      case 'agenda':
        this.hideSection(this.professionalSectionTarget);
        this.hideSection(this.datetimeSectionTarget);
        this.hideSection(this.previewSectionTarget);
        break;
      case 'professional':
        this.hideSection(this.datetimeSectionTarget);
        this.hideSection(this.previewSectionTarget);
        break;
    }
    this.disableSubmit();
  }

  updatePreview(field, value) {
    switch (field) {
      case 'agenda':
        this.agendaNameTarget.textContent = value;
        break;
      case 'professional':
        this.professionalNameTarget.textContent = value;
        break;
      case 'datetime':
        this.scheduledDateTimeTarget.textContent = value;
        break;
    }

    // Verificar se todos os campos estão preenchidos
    const allFieldsFilled =
      this.agendaSelectTarget.value &&
      this.professionalSelectTarget.value &&
      this.dateSelectTarget.value &&
      this.timeSelectTarget.value;

    if (allFieldsFilled) {
      this.showSection(this.previewSectionTarget);
      this.enableSubmit();
    }
  }

  formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('pt-BR');
  }

  clearPreview() {
    this.agendaNameTarget.textContent = '-';
    this.professionalNameTarget.textContent = '-';
    this.scheduledDateTimeTarget.textContent = '-';
    this.hideSection(this.previewSectionTarget);
    this.disableSubmit();
  }

  enableSubmit() {
    this.submitButtonTarget.disabled = false;
  }

  disableSubmit() {
    this.submitButtonTarget.disabled = true;
  }

  showAgendaGrid(agendaId) {
    const gridSection = document.getElementById('agenda-grid-section');
    const gridContent = document.getElementById('agenda-grid-content');

    if (!gridSection || !gridContent) {
      return;
    }

    gridContent.innerHTML =
      '<div class="text-center py-4"><div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div><p class="mt-2 text-sm text-gray-600">Carregando grade de horários...</p></div>';
    gridSection.classList.remove('hidden');

    const professionalId = this.professionalSelectTarget ? this.professionalSelectTarget.value : '';

    if (professionalId === 'all') {
      this.showAllProfessionalsGrid(agendaId);
    } else {
      this.showSingleProfessionalGrid(agendaId, professionalId);
    }
  }

  showSingleProfessionalGrid(agendaId, professionalId) {
    const gridContent = document.getElementById('agenda-grid-content');
    let url = `/admin/portal_intakes/${this.getPortalIntakeId()}/agenda_view?agenda_id=${agendaId}`;
    if (professionalId) {
      url += `&professional_id=${professionalId}`;
    }

    fetch(url)
      .then(response => response.text())
      .then(html => {
        const parser = new DOMParser();
        const doc = parser.parseFromString(html, 'text/html');
        const agendaContent = doc.querySelector('.agenda-grid-content');

        if (agendaContent) {
          gridContent.innerHTML = agendaContent.innerHTML;
        } else {
          gridContent.innerHTML =
            '<div class="text-center py-4 text-red-600">Erro ao carregar a grade de horários</div>';
        }
      })
      .catch(error => {
        gridContent.innerHTML =
          '<div class="text-center py-4 text-red-600">Erro ao carregar a grade de horários</div>';
      });
  }

  showAllProfessionalsGrid(agendaId) {
    const gridContent = document.getElementById('agenda-grid-content');
    const agenda = this.getSelectedAgenda();

    if (!agenda || !agenda.professionals) {
      gridContent.innerHTML =
        '<div class="text-center py-4 text-red-600">Nenhum profissional encontrado</div>';
      return;
    }

    Promise.all(
      agenda.professionals.map(professional => {
        const url = `/admin/portal_intakes/${this.getPortalIntakeId()}/agenda_view?agenda_id=${agendaId}&professional_id=${professional.id}`;
        return fetch(url)
          .then(response => response.text())
          .then(html => {
            const parser = new DOMParser();
            const doc = parser.parseFromString(html, 'text/html');
            const agendaContent = doc.querySelector('.agenda-grid-content');
            return { professional, content: agendaContent ? agendaContent.innerHTML : '' };
          });
      })
    )
      .then(results => {
        let html = '<div class="space-y-6">';

        results.forEach((result, index) => {
          html += `
          <div class="border-b border-gray-200 pb-4">
            <h5 class="text-lg font-semibold text-gray-900 mb-2">${agenda.professionals[index].name}</h5>
            <div>${result.content}</div>
          </div>
        `;
        });

        html += '</div>';
        gridContent.innerHTML = html;
      })
      .catch(error => {
        gridContent.innerHTML =
          '<div class="text-center py-4 text-red-600">Erro ao carregar as grades de horários</div>';
      });
  }

  hideAgendaGrid() {
    const gridSection = document.getElementById('agenda-grid-section');
    if (gridSection) {
      gridSection.classList.add('hidden');
    }
  }

  getPortalIntakeId() {
    if (this.hasPortalIntakeIdValue) {
      return this.portalIntakeIdValue;
    }
    const url = window.location.pathname;
    const matches = url.match(/\/admin\/portal_intakes\/(\d+)/);
    return matches ? matches[1] : null;
  }

  reloadAgendaGrid() {
    const agendaId = this.agendaSelectTarget.value;
    if (agendaId) {
      this.showAgendaGrid(agendaId);
    }
  }
}
