import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  connect() {
    console.log('[ProfessionalsFormController] Controller conectado', this.element);
    this.element.setAttribute('data-turbo-cache', 'false');
    
    const forms = this.element.querySelectorAll('form');
    const buttons = this.element.querySelectorAll('button[data-turbo-method]');
    
    console.log('[ProfessionalsFormController] Formulários encontrados:', forms.length);
    console.log('[ProfessionalsFormController] Botões encontrados:', buttons.length);
    
    forms.forEach((form, index) => {
      console.log(`[ProfessionalsFormController] Formulário ${index}:`, form);
      form.addEventListener('turbo:submit-start', () => {
        console.log('[ProfessionalsFormController] Submit iniciado');
      });
      form.addEventListener('turbo:submit-end', (event) => {
        console.log('[ProfessionalsFormController] Submit finalizado', event.detail);
      });
    });
    
    buttons.forEach((button, index) => {
      console.log(`[ProfessionalsFormController] Botão ${index}:`, button);
      button.addEventListener('turbo:submit-start', () => {
        console.log('[ProfessionalsFormController] Botão submit iniciado');
      });
      button.addEventListener('turbo:submit-end', (event) => {
        console.log('[ProfessionalsFormController] Botão submit finalizado', event.detail);
      });
    });
  }

  disconnect() {
    console.log('[ProfessionalsFormController] Controller desconectado');
  }
}

