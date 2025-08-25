import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  navigate(event) {
    // Não navegar se clicou em um link ou botão
    if (event.target.closest('a') || event.target.closest('button')) {
      return;
    }

    const { url } = this.element.dataset;
    if (url) {
      window.location.href = url;
    }
  }
}
