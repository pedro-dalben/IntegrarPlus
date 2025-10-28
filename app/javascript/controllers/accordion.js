import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['content', 'icon'];

  toggle() {
    const content = this.contentTarget;
    const icon = this.iconTarget;

    if (content.classList.contains('hidden')) {
      // Abrir
      content.classList.remove('hidden');
      icon.style.transform = 'rotate(180deg)';
    } else {
      // Fechar
      content.classList.add('hidden');
      icon.style.transform = 'rotate(0deg)';
    }
  }
}
