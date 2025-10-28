import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['visibilityInfo', 'visibilityText'];

  connect() {
    this.updateVisibilityInfo();
  }

  updateVisibilityInfo() {
    const visibilitySelect = this.element.querySelector('select[name*="default_visibility"]');
    if (visibilitySelect) {
      const selectedValue = visibilitySelect.value;
      this.updateVisibilityText(selectedValue);
    }
  }

  updateVisibilityText(visibility) {
    const texts = {
      private_visibility: 'Privada: Apenas profissionais vinculados podem ver e agendar',
      restricted: 'Restrita: Profissionais e usuários autorizados podem ver e agendar',
      public_visibility: 'Pública: Qualquer usuário pode ver e agendar',
    };

    if (this.hasVisibilityTextTarget) {
      this.visibilityTextTarget.textContent = texts[visibility] || texts['private_visibility'];
    }
  }
}
