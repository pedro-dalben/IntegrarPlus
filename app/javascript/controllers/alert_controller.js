import { Controller } from '@hotwired/stimulus';

export default class AlertController extends Controller {
  static targets = ['modal', 'backdrop', 'content', 'icon', 'title', 'text', 'footer', 'confirmButton', 'cancelButton', 'closeButton'];
  static values = {
    type: String,
    title: String,
    text: String,
    html: String,
    confirmText: String,
    cancelText: String,
    showCancelButton: Boolean,
    showCloseButton: Boolean,
    allowOutsideClick: Boolean,
    allowEscapeKey: Boolean,
    timer: Number,
    width: String,
  };

  connect() {
    this.setupKeyboardListeners();
    this.setupClickListeners();
    this.setupButtonListeners();
  }

  disconnect() {
    this.removeKeyboardListeners();
    this.removeClickListeners();
    this.removeButtonListeners();
    if (this.timerId) clearTimeout(this.timerId);
  }

  static show(options = {}) {
    const defaults = {
      type: 'info',
      title: '',
      text: '',
      html: '',
      confirmText: 'OK',
      cancelText: 'Cancelar',
      showCancelButton: false,
      showCloseButton: false,
      allowOutsideClick: true,
      allowEscapeKey: true,
      timer: null,
      width: '32rem',
      backdropClass: 'bg-white/10 dark:bg-slate-900/30 backdrop-blur-md',
      onConfirm: null,
      onCancel: null,
      onClose: null,
    };

    const config = { ...defaults, ...options };

    const modal = document.createElement('div');
    modal.id = `alert-modal-${Date.now()}`;
    modal.setAttribute('data-controller', 'alert');
    modal.setAttribute('data-alert-type-value', config.type);
    modal.setAttribute('data-alert-title-value', config.title);
    modal.setAttribute('data-alert-text-value', config.text);
    modal.setAttribute('data-alert-html-value', config.html);
    modal.setAttribute('data-alert-confirm-text-value', config.confirmText);
    modal.setAttribute('data-alert-cancel-text-value', config.cancelText);
    modal.setAttribute('data-alert-show-cancel-button-value', config.showCancelButton);
    modal.setAttribute('data-alert-show-close-button-value', config.showCloseButton);
    modal.setAttribute('data-alert-allow-outside-click-value', config.allowOutsideClick);
    modal.setAttribute('data-alert-allow-escape-key-value', config.allowEscapeKey);
    modal.setAttribute('data-alert-width-value', config.width);
    modal.setAttribute('data-alert-backdrop-class-value', config.backdropClass);

    if (config.timer) {
      modal.setAttribute('data-alert-timer-value', config.timer);
    }

    modal.innerHTML = AlertController.getModalHTML(config);
    document.body.appendChild(modal);

    return new Promise((resolve) => {
      let attempts = 0;
      const maxAttempts = 100;
      
      const showModal = () => {
        attempts++;
        const controllerElement = document.getElementById(modal.id);

        if (!controllerElement) {
          if (attempts < maxAttempts) {
            setTimeout(showModal, 50);
          } else {
            resolve({ isConfirmed: false, isDismissed: true });
          }
          return;
        }

        const controller = AlertController.getControllerInstance(controllerElement);

        if (controller) {
          controller.config = config;
          controller.resolve = resolve;
          requestAnimationFrame(() => {
            controller.show();
          });
        } else {
          if (attempts < maxAttempts) {
            setTimeout(showModal, 50);
          } else {
            resolve({ isConfirmed: false, isDismissed: true });
          }
        }
      };

      setTimeout(showModal, 50);
    });
  }

  static getControllerInstance(element) {
    if (window.Stimulus?.application) {
      const controller = window.Stimulus.application.getControllerForElementAndIdentifier(element, 'alert');
      return controller;
    }

    const controllers = window.Stimulus?.controllers || [];
    const controller = controllers.find(c => c.element === element);
    if (controller) {
      return controller;
    }

    if (element.controller) {
      return element.controller;
    }

    const application = document.querySelector('[data-controller]')?.controller?.application;
    if (application) {
      const controller = application.getControllerForElementAndIdentifier(element, 'alert');
      return controller;
    }

    return null;
  }

  static getModalHTML(config) {
    const icon = this.getIconHTML(config.type);
    return `
      <div class="fixed inset-0 z-[9998]" style="pointer-events: none;">
        <div data-alert-target="backdrop" class="fixed inset-0 ${config.backdropClass} backdrop-blur-sm transition-opacity opacity-0" style="pointer-events: auto; z-index: 9998;"></div>
        <div data-alert-target="modal" class="fixed inset-0 flex items-center justify-center p-4" style="pointer-events: none; z-index: 9999;">
          <div data-alert-target="content" class="bg-white dark:bg-gray-800 rounded-2xl shadow-2xl transform transition-all scale-95 opacity-0 w-full max-h-[90vh] overflow-hidden flex flex-col relative" style="max-width: ${config.width}; pointer-events: auto; z-index: 10000; position: relative;">
          ${config.showCloseButton ? `
            <button data-alert-target="closeButton" 
                    data-action="click->alert#close"
                    class="absolute right-4 top-4 z-10 w-8 h-8 flex items-center justify-center rounded-full bg-gray-100 dark:bg-gray-700 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 transition-colors">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
              </svg>
            </button>
          ` : ''}
          <div class="p-6 flex-1 overflow-y-auto">
            <div class="text-center">
              <div data-alert-target="icon" class="inline-flex items-center justify-center w-16 h-16 rounded-full mb-4">
                ${icon}
              </div>
              ${config.title ? `<h3 data-alert-target="title" class="text-xl font-semibold text-gray-900 dark:text-white mb-2">${config.title}</h3>` : ''}
              ${config.html ? `<div data-alert-target="text" class="text-sm text-gray-600 dark:text-gray-300 mb-4">${config.html}</div>` : ''}
              ${config.text && !config.html ? `<p data-alert-target="text" class="text-sm text-gray-600 dark:text-gray-300 mb-4">${config.text}</p>` : ''}
            </div>
          </div>
          <div data-alert-target="footer" class="px-6 py-4 bg-gray-50 dark:bg-gray-900 border-t border-gray-200 dark:border-gray-700 flex items-center justify-end gap-3" style="position: relative; z-index: 10001;">
            ${config.showCancelButton ? `
              <button data-alert-target="cancelButton"
                      data-action="click->alert#cancel"
                      class="px-4 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-600 rounded-lg shadow-sm transition-all duration-200 hover:bg-gray-50 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-300 dark:focus:ring-gray-700"
                      style="position: relative; z-index: 10002; pointer-events: auto; cursor: pointer;">
                ${config.cancelText}
              </button>
            ` : ''}
            <button data-alert-target="confirmButton"
                    data-action="click->alert#confirm"
                    class="px-4 py-2 text-sm font-medium text-white rounded-lg shadow-sm transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2 ${this.getButtonClass(config.type)}"
                    style="position: relative; z-index: 10002; pointer-events: auto; cursor: pointer;">
              ${config.confirmText}
            </button>
          </div>
        </div>
      </div>
    `;
  }

  static getIconHTML(type) {
    const icons = {
      success: `
        <svg class="w-8 h-8 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
        </svg>
      `,
      error: `
        <svg class="w-8 h-8 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
        </svg>
      `,
      warning: `
        <svg class="w-8 h-8 text-yellow-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path>
        </svg>
      `,
      info: `
        <svg class="w-8 h-8 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
        </svg>
      `,
      question: `
        <svg class="w-8 h-8 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
        </svg>
      `,
    };

    return icons[type] || icons.info;
  }

  static getButtonClass(type) {
    const classes = {
      success: 'bg-green-500 hover:bg-green-600 focus:ring-green-400',
      error: 'bg-red-500 hover:bg-red-600 focus:ring-red-400',
      warning: 'bg-yellow-500 hover:bg-yellow-600 focus:ring-yellow-400',
      info: 'bg-blue-500 hover:bg-blue-600 focus:ring-blue-400',
      question: 'bg-gray-500 hover:bg-gray-600 focus:ring-gray-400',
    };

    return classes[type] || classes.info;
  }

  show() {
    const iconBgClasses = {
      success: 'bg-green-100 dark:bg-green-900',
      error: 'bg-red-100 dark:bg-red-900',
      warning: 'bg-yellow-100 dark:bg-yellow-900',
      info: 'bg-blue-100 dark:bg-blue-900',
      question: 'bg-gray-100 dark:bg-gray-700',
    };

    if (this.hasIconTarget) {
      this.iconTarget.className = `inline-flex items-center justify-center w-16 h-16 rounded-full mb-4 ${iconBgClasses[this.typeValue] || iconBgClasses.info}`;
    }

    this.setupButtonListeners();

    requestAnimationFrame(() => {
      if (this.hasBackdropTarget) {
        this.backdropTarget.classList.remove('opacity-0');
        this.backdropTarget.classList.add('opacity-100');
      }
      if (this.hasContentTarget) {
        this.contentTarget.classList.remove('scale-95', 'opacity-0');
        this.contentTarget.classList.add('scale-100', 'opacity-100');
      }
    });

    if (this.timerValue > 0) {
      this.timerId = setTimeout(() => {
        this.confirm();
      }, this.timerValue);
    }
  }

  hide() {
    if (this.hasBackdropTarget) {
      this.backdropTarget.classList.remove('opacity-100');
      this.backdropTarget.classList.add('opacity-0');
    }
    if (this.hasContentTarget) {
      this.contentTarget.classList.remove('scale-100', 'opacity-100');
      this.contentTarget.classList.add('scale-95', 'opacity-0');
    }

    setTimeout(() => {
      this.element.remove();
    }, 300);
  }

  confirm() {
    if (this.timerId) clearTimeout(this.timerId);
    
    if (this.config?.onConfirm) {
      this.config.onConfirm();
    }

    if (this.resolve) {
      this.resolve({ isConfirmed: true, isDismissed: false });
      this.resolve = null;
    }

    this.hide();
  }

  cancel() {
    if (this.timerId) clearTimeout(this.timerId);
    
    if (this.config?.onCancel) {
      this.config.onCancel();
    }

    if (this.resolve) {
      this.resolve({ isConfirmed: false, isDismissed: false });
      this.resolve = null;
    }

    this.hide();
  }

  close() {
    if (this.timerId) clearTimeout(this.timerId);
    
    if (this.config?.onClose) {
      this.config.onClose();
    }

    if (this.resolve) {
      this.resolve({ isConfirmed: false, isDismissed: true });
      this.resolve = null;
    }

    this.hide();
  }

  setupKeyboardListeners() {
    if (this.allowEscapeKeyValue) {
      this.boundHandleEscape = this.handleEscape.bind(this);
      document.addEventListener('keydown', this.boundHandleEscape);
    }
  }

  removeKeyboardListeners() {
    if (this.boundHandleEscape) {
      document.removeEventListener('keydown', this.boundHandleEscape);
    }
  }

  handleEscape(event) {
    if (event.key === 'Escape' && this.allowEscapeKeyValue) {
      this.close();
    }
  }

  setupClickListeners() {
    if (this.allowOutsideClickValue && this.hasBackdropTarget) {
      this.boundHandleBackdropClick = this.handleBackdropClick.bind(this);
      this.backdropTarget.addEventListener('click', this.boundHandleBackdropClick, { capture: false });
    }
  }

  removeClickListeners() {
    if (this.boundHandleBackdropClick && this.hasBackdropTarget) {
      this.backdropTarget.removeEventListener('click', this.boundHandleBackdropClick, { capture: false });
    }
  }

  handleBackdropClick(event) {
    if (!this.allowOutsideClickValue) {
      event.stopPropagation();
      return;
    }
    
    if (this.hasContentTarget && (event.target === this.contentTarget || this.contentTarget.contains(event.target))) {
      event.stopPropagation();
      event.preventDefault();
      return;
    }
    
    if (event.target.closest && event.target.closest('[data-alert-target="modal"]')) {
      event.stopPropagation();
      event.preventDefault();
      return;
    }
    
    if (event.target.closest && (event.target.closest('[data-alert-target="confirmButton"]') || event.target.closest('[data-alert-target="cancelButton"]') || event.target.closest('[data-alert-target="closeButton"]'))) {
      event.stopPropagation();
      event.preventDefault();
      return;
    }
    
    if (event.target === event.currentTarget && event.target === this.backdropTarget) {
      this.close();
    } else {
      event.stopPropagation();
    }
  }

  setupButtonListeners() {
    if (this.hasConfirmButtonTarget) {
      if (this.boundHandleConfirm) {
        this.confirmButtonTarget.removeEventListener('click', this.boundHandleConfirm, { capture: true });
        this.confirmButtonTarget.removeEventListener('click', this.boundHandleConfirm, { capture: false });
        this.confirmButtonTarget.onclick = null;
      }
      this.boundHandleConfirm = (event) => {
        event.preventDefault();
        event.stopPropagation();
        event.stopImmediatePropagation();
        setTimeout(() => {
          this.confirm();
        }, 0);
      };
      this.confirmButtonTarget.addEventListener('click', this.boundHandleConfirm, { capture: true });
      this.confirmButtonTarget.addEventListener('click', this.boundHandleConfirm, { capture: false });
      this.confirmButtonTarget.onclick = this.boundHandleConfirm;
      this.confirmButtonTarget.style.pointerEvents = 'auto';
      this.confirmButtonTarget.style.cursor = 'pointer';
    }

    if (this.hasCancelButtonTarget) {
      if (this.boundHandleCancel) {
        this.cancelButtonTarget.removeEventListener('click', this.boundHandleCancel, { capture: true });
        this.cancelButtonTarget.removeEventListener('click', this.boundHandleCancel, { capture: false });
        this.cancelButtonTarget.onclick = null;
      }
      this.boundHandleCancel = (event) => {
        event.preventDefault();
        event.stopPropagation();
        event.stopImmediatePropagation();
        setTimeout(() => {
          this.cancel();
        }, 0);
      };
      this.cancelButtonTarget.addEventListener('click', this.boundHandleCancel, { capture: true });
      this.cancelButtonTarget.addEventListener('click', this.boundHandleCancel, { capture: false });
      this.cancelButtonTarget.onclick = this.boundHandleCancel;
      this.cancelButtonTarget.style.pointerEvents = 'auto';
      this.cancelButtonTarget.style.cursor = 'pointer';
    }

    if (this.hasCloseButtonTarget) {
      if (this.boundHandleClose) {
        this.closeButtonTarget.removeEventListener('click', this.boundHandleClose, { capture: true });
        this.closeButtonTarget.removeEventListener('click', this.boundHandleClose, { capture: false });
        this.closeButtonTarget.onclick = null;
      }
      this.boundHandleClose = (event) => {
        event.preventDefault();
        event.stopPropagation();
        event.stopImmediatePropagation();
        setTimeout(() => {
          this.close();
        }, 0);
      };
      this.closeButtonTarget.addEventListener('click', this.boundHandleClose, { capture: true });
      this.closeButtonTarget.addEventListener('click', this.boundHandleClose, { capture: false });
      this.closeButtonTarget.onclick = this.boundHandleClose;
      this.closeButtonTarget.style.pointerEvents = 'auto';
      this.closeButtonTarget.style.cursor = 'pointer';
    }
  }

  removeButtonListeners() {
    if (this.boundHandleConfirm && this.hasConfirmButtonTarget) {
      this.confirmButtonTarget.removeEventListener('click', this.boundHandleConfirm, { capture: true });
      this.confirmButtonTarget.removeEventListener('click', this.boundHandleConfirm, { capture: false });
      this.confirmButtonTarget.onclick = null;
      this.boundHandleConfirm = null;
    }

    if (this.boundHandleCancel && this.hasCancelButtonTarget) {
      this.cancelButtonTarget.removeEventListener('click', this.boundHandleCancel, { capture: true });
      this.cancelButtonTarget.removeEventListener('click', this.boundHandleCancel, { capture: false });
      this.cancelButtonTarget.onclick = null;
      this.boundHandleCancel = null;
    }

    if (this.boundHandleClose && this.hasCloseButtonTarget) {
      this.closeButtonTarget.removeEventListener('click', this.boundHandleClose, { capture: true });
      this.closeButtonTarget.removeEventListener('click', this.boundHandleClose, { capture: false });
      this.closeButtonTarget.onclick = null;
      this.boundHandleClose = null;
    }
  }

  static alert(title, text = '', options = {}) {
    return this.show({ type: 'info', title, text, ...options });
  }

  static success(title, text = '', options = {}) {
    return this.show({ type: 'success', title, text, ...options });
  }

  static error(title, text = '', options = {}) {
    return this.show({ type: 'error', title, text, ...options });
  }

  static warning(title, text = '', options = {}) {
    return this.show({ type: 'warning', title, text, ...options });
  }

  static info(title, text = '', options = {}) {
    return this.show({ type: 'info', title, text, ...options });
  }

  static question(title, text = '', options = {}) {
    return this.show({ type: 'question', title, text, showCancelButton: true, ...options });
  }

  static confirm(title, text = '', options = {}) {
    return this.show({
      type: 'question',
      title,
      text,
      showCancelButton: true,
      confirmText: options.confirmText || 'Confirmar',
      cancelText: options.cancelText || 'Cancelar',
      ...options,
    });
  }


}
