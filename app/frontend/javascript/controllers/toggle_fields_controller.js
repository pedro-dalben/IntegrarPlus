import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['trigger', 'content'];
  static values = {
    showWhen: { type: String, default: 'checked' },
  };

  connect() {
    this.update();
  }

  update() {
    const trigger = this.hasTriggerTarget ? this.triggerTarget : this.element;
    const isChecked = trigger.checked;

    this.contentTargets.forEach(content => {
      if (this.showWhenValue === 'checked') {
        content.style.display = isChecked ? '' : 'none';
      } else if (this.showWhenValue === 'unchecked') {
        content.style.display = isChecked ? 'none' : '';
      }
    });
  }
}
