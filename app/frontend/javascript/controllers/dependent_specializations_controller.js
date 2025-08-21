import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["specialitySelect", "specializationSelect"];
  static values = { endpoint: String };

  connect() {
    console.log("DependentSpecializations controller connected");
  }

  specialityChanged() {
    const specialityIds = this.getSelectedSpecialityIds();
    console.log("Specialities changed:", specialityIds);
    
    if (specialityIds.length === 0) {
      this.clearSpecializations();
      return;
    }

    this.loadSpecializations(specialityIds);
  }

  getSelectedSpecialityIds() {
    if (this.hasSpecialitySelectTarget) {
      const tomSelectInstance = this.specialitySelectTarget.tomselect;
      if (tomSelectInstance) {
        return tomSelectInstance.getValue();
      }
      
      // Fallback para select múltiplo normal
      return Array.from(this.specialitySelectTarget.selectedOptions)
                  .map(option => option.value)
                  .filter(value => value !== "");
    }
    return [];
  }

  async loadSpecializations(specialityIds) {
    try {
      const url = new URL(this.endpointValue, window.location.origin);
      url.searchParams.set('speciality_ids', specialityIds.join(','));
      
      console.log("Loading specializations from:", url.toString());
      
      const response = await fetch(url);
      console.log("Response status:", response.status);
      
      if (!response.ok) {
        const errorText = await response.text();
        console.error("Response error:", errorText);
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      const data = await response.json();
      console.log("Loaded specializations:", data);
      this.updateSpecializationOptions(data);
    } catch (error) {
      console.error("Error loading specializations:", error);
      this.clearSpecializations();
    }
  }

  updateSpecializationOptions(specializations) {
    if (!this.hasSpecializationSelectTarget) return;

    const tomSelectInstance = this.specializationSelectTarget.tomselect;
    
    if (tomSelectInstance) {
      // TomSelect instance
      tomSelectInstance.clearOptions();
      tomSelectInstance.clear();
      
      specializations.forEach(spec => {
        tomSelectInstance.addOption({
          value: spec.id,
          text: spec.name
        });
      });
    } else {
      // Fallback para select normal
      this.specializationSelectTarget.innerHTML = '<option value="">Selecione as especializações...</option>';
      
      specializations.forEach(spec => {
        const option = document.createElement('option');
        option.value = spec.id;
        option.textContent = spec.name;
        this.specializationSelectTarget.appendChild(option);
      });
    }
  }

  clearSpecializations() {
    if (!this.hasSpecializationSelectTarget) return;

    const tomSelectInstance = this.specializationSelectTarget.tomselect;
    
    if (tomSelectInstance) {
      tomSelectInstance.clearOptions();
      tomSelectInstance.clear();
    } else {
      this.specializationSelectTarget.innerHTML = '<option value="">Selecione as especializações...</option>';
    }
  }
}
