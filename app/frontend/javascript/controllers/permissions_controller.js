import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['granteeTypeSelect', 'userSelect', 'groupSelect'];

  connect() {
    this.initializeGranteeType();
  }

  toggleGranteeType() {
    const granteeTypeSelect = this.granteeTypeSelectTarget;
    if (!granteeTypeSelect) {
      return;
    }

    const granteeType = granteeTypeSelect.value;

    if (granteeType === 'user') {
      this.showUserSelect();
    } else if (granteeType === 'group') {
      this.showGroupSelect();
    }
  }

  showUserSelect() {
    if (this.hasUserSelectTarget) {
      this.userSelectTarget.classList.remove('hidden');
    }
    if (this.hasGroupSelectTarget) {
      this.groupSelectTarget.classList.add('hidden');
    }
  }

  showGroupSelect() {
    if (this.hasUserSelectTarget) {
      this.userSelectTarget.classList.add('hidden');
    }
    if (this.hasGroupSelectTarget) {
      this.groupSelectTarget.classList.remove('hidden');
    }
  }

  initializeGranteeType() {
    this.toggleGranteeType();
  }
}
