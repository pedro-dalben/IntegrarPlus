import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['specialitySelect', 'specializationSelect'];
  static values = { endpoint: String };

  connect() {
    if (!this.hasSpecialitySelectTarget || !this.hasSpecializationSelectTarget) {
      return;
    }

    this.setupEventListeners();
  }

  setupEventListeners() {
    this.specialitySelectTarget.addEventListener('change', () => {
      this.specialityChanged();
    });

    // Também tentar configurar listeners do Tom Select se disponível
    this.waitForTomSelectAndSetupListeners();
  }

  waitForTomSelectAndSetupListeners() {
    const maxAttempts = 20;
    let attempts = 0;

    const checkTomSelect = () => {
      attempts++;

      const specialityTomSelect = this.specialitySelectTarget.tomselect;
      if (specialityTomSelect) {
        specialityTomSelect.on('change', () => {
          this.specialityChanged();
        });

        specialityTomSelect.on('item_add', () => {
          this.specialityChanged();
        });

        specialityTomSelect.on('item_remove', () => {
          this.specialityChanged();
        });
      } else if (attempts < maxAttempts) {
        setTimeout(checkTomSelect, 100);
      } else {
      }
    };

    checkTomSelect();
  }

  specialityChanged() {
    this.loadSpecializations();
  }

  async loadSpecializations() {
    if (!this.hasSpecialitySelectTarget || !this.hasSpecializationSelectTarget) {
      return;
    }

    const specialityIds = Array.from(this.specialitySelectTarget.selectedOptions).map(
      option => option.value
    );

    if (specialityIds.length === 0) {
      this.specializationSelectTarget.innerHTML =
        '<option value="">Selecione as especializações...</option>';
      this.reinitializeTomSelect();
      return;
    }

    try {
      const url = new URL('/admin/specializations/by_speciality', window.location.origin);
      specialityIds.forEach(id => url.searchParams.append('speciality_ids[]', id));

      const response = await fetch(url.toString());

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();

      // Limpar opções existentes
      this.specializationSelectTarget.innerHTML = '';

      // Adicionar opção padrão
      const defaultOption = document.createElement('option');
      defaultOption.value = '';
      defaultOption.textContent = 'Selecione as especializações...';
      this.specializationSelectTarget.appendChild(defaultOption);

      // Adicionar novas opções
      data.forEach(specialization => {
        const option = document.createElement('option');
        option.value = specialization.id;
        option.textContent = `${specialization.name} (${specialization.speciality_name})`;
        this.specializationSelectTarget.appendChild(option);
      });

      this.reinitializeTomSelect();
    } catch (error) {
      this.specializationSelectTarget.innerHTML =
        '<option value="">Erro ao carregar especializações</option>';
      this.reinitializeTomSelect();
    }
  }

  reinitializeTomSelect() {
    const tomSelectInstance = this.specializationSelectTarget.tomselect;
    if (tomSelectInstance) {
      // Limpar seleções atuais
      tomSelectInstance.clear();

      // Atualizar opções disponíveis
      tomSelectInstance.clearOptions();

      // Adicionar opção padrão
      tomSelectInstance.addOption({
        value: '',
        text: 'Selecione as especializações...',
      });

      // Adicionar todas as opções do select
      const options = Array.from(this.specializationSelectTarget.options);
      options.forEach(option => {
        if (option.value !== '') {
          tomSelectInstance.addOption({
            value: option.value,
            text: option.textContent,
          });
        }
      });

      // Forçar atualização da interface
      tomSelectInstance.refreshOptions();
      tomSelectInstance.refreshItems();
    } else {
    }
  }

  disconnect() {
    const specialityTomSelect = this.specialitySelectTarget.tomselect;
    if (specialityTomSelect) {
      specialityTomSelect.off('change');
      specialityTomSelect.off('item_add');
      specialityTomSelect.off('item_remove');
    }
  }
}
