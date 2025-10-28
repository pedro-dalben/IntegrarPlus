import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static values = {
    timeoutMinutes: Number,
    warningMinutes: Number,
    logoutUrl: String,
    isProduction: Boolean,
  };

  static targets = ['warning', 'countdown'];

  connect() {
    this.timeoutMs = this.timeoutMinutesValue * 60 * 1000;
    this.warningMs = this.warningMinutesValue * 60 * 1000;
    this.warningShown = false;
    this.lastActivity = Date.now();

    this.setupEventListeners();
    this.startTimer();
  }

  disconnect() {
    this.clearTimers();
    this.removeEventListeners();
  }

  setupEventListeners() {
    const events = ['mousedown', 'keypress', 'keydown', 'click', 'touchstart'];

    events.forEach(event => {
      document.addEventListener(event, this.resetTimer.bind(this), true);
    });

    window.addEventListener('beforeunload', this.clearTimers.bind(this));
  }

  removeEventListeners() {
    const events = ['mousedown', 'keypress', 'keydown', 'click', 'touchstart'];

    events.forEach(event => {
      document.removeEventListener(event, this.resetTimer.bind(this), true);
    });

    window.removeEventListener('beforeunload', this.clearTimers.bind(this));
  }

  resetTimer() {
    this.lastActivity = Date.now();
    this.warningShown = false;

    if (this.warningTarget) {
      this.warningTarget.classList.add('hidden');
    }

    this.clearTimers();
    this.startTimer();
  }

  startTimer() {
    this.timeoutTimer = setTimeout(() => {
      this.showWarning();
    }, this.timeoutMs);
  }

  clearTimers() {
    if (this.timeoutTimer) {
      clearTimeout(this.timeoutTimer);
      this.timeoutTimer = null;
    }

    if (this.logoutTimer) {
      clearTimeout(this.logoutTimer);
      this.logoutTimer = null;
    }

    if (this.countdownTimer) {
      clearInterval(this.countdownTimer);
      this.countdownTimer = null;
    }
  }

  showWarning() {
    if (this.warningShown) return;

    this.warningShown = true;

    if (this.warningTarget) {
      this.warningTarget.classList.remove('hidden');
    }

    this.startCountdown();
  }

  startCountdown() {
    let secondsLeft = 30;

    this.countdownTimer = setInterval(() => {
      if (this.countdownTarget) {
        this.countdownTarget.textContent = secondsLeft;
      }

      if (secondsLeft <= 0) {
        this.logout();
        return;
      }

      secondsLeft--;
    }, 1000);
  }

  extendSession() {
    this.resetTimer();
  }

  logout() {
    this.clearTimers();

    if (this.logoutUrlValue) {
      // Criar um formulário para fazer DELETE request
      const form = document.createElement('form');
      form.method = 'POST';
      form.action = this.logoutUrlValue;

      // Adicionar token CSRF
      const csrfToken = document.querySelector('meta[name="csrf-token"]');
      if (csrfToken) {
        const csrfInput = document.createElement('input');
        csrfInput.type = 'hidden';
        csrfInput.name = 'authenticity_token';
        csrfInput.value = csrfToken.getAttribute('content');
        form.appendChild(csrfInput);
      }

      // Adicionar método DELETE
      const methodInput = document.createElement('input');
      methodInput.type = 'hidden';
      methodInput.name = '_method';
      methodInput.value = 'delete';
      form.appendChild(methodInput);

      // Submeter o formulário
      document.body.appendChild(form);
      form.submit();
    } else {
      window.location.reload();
    }
  }
}
