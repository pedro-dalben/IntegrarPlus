import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['viewContent', 'editContent', 'toggleButton'];

  connect() {
    if (this.element.dataset.editing === 'true') {
      this.enterEditMode();
    }
  }

  toggle() {
    const isEditing = this.element.dataset.editing === 'true';

    if (isEditing) {
      this.exitEditMode();
    } else {
      this.enterEditMode();
    }
  }

  enterEditMode() {
    this.element.dataset.editing = 'true';

    this.viewContentTargets.forEach(el => (el.style.display = 'none'));
    this.editContentTargets.forEach(el => (el.style.display = ''));

    if (this.hasToggleButtonTarget) {
      this.toggleButtonTargets.forEach(btn => {
        btn.textContent = 'Cancelar';
        btn.classList.remove('bg-brand-500', 'hover:bg-brand-600');
        btn.classList.add('bg-gray-500', 'hover:bg-gray-600');
      });
    }
  }

  exitEditMode() {
    this.element.dataset.editing = 'false';

    this.viewContentTargets.forEach(el => (el.style.display = ''));
    this.editContentTargets.forEach(el => (el.style.display = 'none'));

    if (this.hasToggleButtonTarget) {
      this.toggleButtonTargets.forEach(btn => {
        btn.textContent = 'Editar';
        btn.classList.remove('bg-gray-500', 'hover:bg-gray-600');
        btn.classList.add('bg-brand-500', 'hover:bg-brand-600');
      });
    }
  }
}
