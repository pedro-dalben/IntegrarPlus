import AlertController from './controllers/alert_controller.js';

window.Alert = {
  show: (options) => AlertController.show(options),
  alert: (title, text, options) => AlertController.alert(title, text, options),
  success: (title, text, options) => AlertController.success(title, text, options),
  error: (title, text, options) => AlertController.error(title, text, options),
  warning: (title, text, options) => AlertController.warning(title, text, options),
  info: (title, text, options) => AlertController.info(title, text, options),
  question: (title, text, options) => AlertController.question(title, text, options),
  confirm: (title, text, options) => AlertController.confirm(title, text, options),
};

// Interceptação automática de alert() nativo
if (typeof window.originalAlert === 'undefined') {
  window.originalAlert = window.alert;
  window.alert = function(message, title = 'Aviso') {
    if (window.Alert) {
      return window.Alert.alert(title, message);
    } else {
      return window.originalAlert(message);
    }
  };
}

// Interceptação automática de confirm() nativo
// NOTA: confirm() nativo é síncrono, mas nosso sistema é assíncrono
// Para código que precisa de confirm() síncrono, mantemos o nativo como fallback
// Para novos códigos, recomendamos usar window.Alert.confirm() diretamente
if (typeof window.originalConfirm === 'undefined') {
  window.originalConfirm = window.confirm;
  window.confirm = function(message, title = 'Confirmar') {
    // Se o código está chamando confirm() síncrono, mostramos um aviso no console
    // e usamos o confirm nativo como fallback
    console.warn('confirm() nativo foi chamado. Para melhor UX, considere usar window.Alert.confirm() que retorna uma Promise.');
    
    // Usamos o confirm nativo para manter compatibilidade com código síncrono
    // Mas podemos oferecer uma alternativa melhor
    if (window.Alert && typeof title === 'string') {
      // Se passaram um título como segundo parâmetro, usamos nosso sistema
      // Mas isso requer que o código seja refatorado para usar async/await
      // Por enquanto, mantemos o comportamento nativo para compatibilidade máxima
      return window.originalConfirm(message);
    }
    
    return window.originalConfirm(message);
  };
}

// Interceptação automática de prompt() nativo
if (typeof window.originalPrompt === 'undefined') {
  window.originalPrompt = window.prompt;
  window.prompt = function(message, defaultValue = '', title = 'Entrada') {
    if (window.Alert) {
      // Prompt customizado com input
      return new Promise((resolve) => {
        const inputId = `alert-input-${Date.now()}`;
        const html = `
          <div class="mt-4">
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">${message}</label>
            <input type="text" 
                   id="${inputId}" 
                   value="${defaultValue}" 
                   class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-white"
                   autofocus>
          </div>
        `;
        
        window.Alert.show({
          type: 'question',
          title: title,
          html: html,
          confirmText: 'OK',
          cancelText: 'Cancelar',
          showCancelButton: true,
          onConfirm: () => {
            const input = document.getElementById(inputId);
            resolve(input ? input.value : null);
          },
          onCancel: () => {
            resolve(null);
          }
        });
        
        // Focar no input após o modal abrir
        setTimeout(() => {
          const input = document.getElementById(inputId);
          if (input) {
            input.focus();
            input.select();
          }
        }, 300);
      });
    } else {
      return Promise.resolve(window.originalPrompt(message, defaultValue));
    }
  };
}

// Interceptação de Flash Messages do Rails
document.addEventListener('DOMContentLoaded', () => {
  interceptFlashMessages();
});

// Também interceptar quando há mudanças no DOM (Turbo)
document.addEventListener('turbo:load', () => {
  interceptFlashMessages();
});

function interceptFlashMessages() {
  // Buscar flash messages no formato Rails padrão
  const flashNotice = document.querySelector('.notice, [data-notice], .alert-success, .flash-notice');
  const flashAlert = document.querySelector('.alert, [data-alert], .alert-danger, .flash-alert');
  const flashWarning = document.querySelector('.warning, [data-warning], .alert-warning, .flash-warning');
  const flashInfo = document.querySelector('.info, [data-info], .alert-info, .flash-info');

  if (flashNotice && window.Alert) {
    const message = flashNotice.textContent.trim();
    if (message) {
      window.Alert.success('Sucesso', message, {
        timer: 4000,
        showCloseButton: true
      });
      flashNotice.remove();
    }
  }

  if (flashAlert && window.Alert) {
    const message = flashAlert.textContent.trim();
    if (message) {
      window.Alert.error('Erro', message, {
        timer: 5000,
        showCloseButton: true
      });
      flashAlert.remove();
    }
  }

  if (flashWarning && window.Alert) {
    const message = flashWarning.textContent.trim();
    if (message) {
      window.Alert.warning('Atenção', message, {
        timer: 4000,
        showCloseButton: true
      });
      flashWarning.remove();
    }
  }

  if (flashInfo && window.Alert) {
    const message = flashInfo.textContent.trim();
    if (message) {
      window.Alert.info('Informação', message, {
        timer: 4000,
        showCloseButton: true
      });
      flashInfo.remove();
    }
  }

  // Interceptar flash messages do Hotwire/Turbo
  const turboFrame = document.querySelector('turbo-frame[data-turbo-frame]');
  if (turboFrame) {
    const turboFlash = turboFrame.querySelector('.notice, .alert, .warning, .info');
    if (turboFlash && window.Alert) {
      const message = turboFlash.textContent.trim();
      const type = turboFlash.classList.contains('notice') || turboFlash.classList.contains('alert-success') ? 'success' :
                   turboFlash.classList.contains('alert') || turboFlash.classList.contains('alert-danger') ? 'error' :
                   turboFlash.classList.contains('warning') || turboFlash.classList.contains('alert-warning') ? 'warning' : 'info';
      
      if (message) {
        window.Alert[type === 'error' ? 'error' : type === 'warning' ? 'warning' : type === 'success' ? 'success' : 'info'](
          type === 'error' ? 'Erro' : type === 'warning' ? 'Atenção' : type === 'success' ? 'Sucesso' : 'Informação',
          message,
          { timer: 4000, showCloseButton: true }
        );
        turboFlash.remove();
      }
    }
  }
}

// Interceptar flash messages via Turbo Streams
document.addEventListener('turbo:before-stream-render', (event) => {
  const streamElement = event.target;
  const template = streamElement.templateElement;
  
  if (template && template.content) {
    const notice = template.content.querySelector('.notice, [data-notice]');
    const alert = template.content.querySelector('.alert, [data-alert]');
    const warning = template.content.querySelector('.warning, [data-warning]');
    const info = template.content.querySelector('.info, [data-info]');
    
    if (notice && window.Alert) {
      const message = notice.textContent.trim();
      if (message) {
        event.preventDefault();
        window.Alert.success('Sucesso', message, { timer: 4000, showCloseButton: true });
      }
    }
    
    if (alert && window.Alert) {
      const message = alert.textContent.trim();
      if (message) {
        event.preventDefault();
        window.Alert.error('Erro', message, { timer: 5000, showCloseButton: true });
      }
    }
    
    if (warning && window.Alert) {
      const message = warning.textContent.trim();
      if (message) {
        event.preventDefault();
        window.Alert.warning('Atenção', message, { timer: 4000, showCloseButton: true });
      }
    }
    
    if (info && window.Alert) {
      const message = info.textContent.trim();
      if (message) {
        event.preventDefault();
        window.Alert.info('Informação', message, { timer: 4000, showCloseButton: true });
      }
    }
  }
});

// Sistema de tipos de alerta customizados
window.Alert.types = {
  success: {
    icon: 'success',
    color: 'green',
    title: 'Sucesso'
  },
  error: {
    icon: 'error',
    color: 'red',
    title: 'Erro'
  },
  warning: {
    icon: 'warning',
    color: 'yellow',
    title: 'Atenção'
  },
  info: {
    icon: 'info',
    color: 'blue',
    title: 'Informação'
  },
  question: {
    icon: 'question',
    color: 'gray',
    title: 'Pergunta'
  }
};

// Adicionar métodos de conveniência para tipos específicos
window.Alert.danger = (title, text, options) => window.Alert.error(title, text, options);
window.Alert.warn = (title, text, options) => window.Alert.warning(title, text, options);

export default window.Alert;
