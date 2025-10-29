import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  toggle(event) {
    event.preventDefault();
    const targetId = event.currentTarget.dataset.toggleTargetValue;
    const targetElement = document.getElementById(targetId);

    if (targetElement) {
      targetElement.classList.toggle('hidden');
    }
  }
}
