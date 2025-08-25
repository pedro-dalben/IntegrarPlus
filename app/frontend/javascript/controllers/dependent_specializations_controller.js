import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['specialitySelect', 'specializationSelect'];
  static values = { endpoint: String };

  connect() {
    this.initializeSpecializations();
  }

  specialitiesChanged() {
    this.loadSpecializations();
  }

  initializeSpecializations() {
    this.loadSpecializations();
  }

  async loadSpecializations() {
    const specialityIds = Array.from(this.specialitySelectTarget.selectedOptions).map(
      option => option.value
    );

    if (specialityIds.length === 0) {
      this.specializationSelectTarget.innerHTML =
        '<option value="">Selecione uma especialização</option>';
      return;
    }

    try {
      const url = new URL('/admin/specializations/by_specialities', window.location.origin);
      specialityIds.forEach(id => url.searchParams.append('speciality_ids[]', id));

      const response = await fetch(url.toString());

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();

      this.specializationSelectTarget.innerHTML =
        '<option value="">Selecione uma especialização</option>';

      data.forEach(specialization => {
        const option = document.createElement('option');
        option.value = specialization.id;
        option.textContent = `${specialization.name} (${specialization.speciality_name})`;
        this.specializationSelectTarget.appendChild(option);
      });
    } catch (error) {
      this.specializationSelectTarget.innerHTML =
        '<option value="">Erro ao carregar especializações</option>';
    }
  }
}
