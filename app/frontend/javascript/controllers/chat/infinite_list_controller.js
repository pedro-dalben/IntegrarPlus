import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static values = { streamName: String, currentUserId: Number };

  connect() {
    this.scrollToBottom();
    setTimeout(() => this.applyMessageStyling(), 100);

    this.observer = new MutationObserver(() => {
      setTimeout(() => {
        this.applyMessageStyling();
        this.scrollToBottom();
      }, 50);
    });

    this.observer.observe(this.element, {
      childList: true,
      subtree: true,
    });
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect();
    }
  }

  applyMessageStyling() {
    if (!this.hasCurrentUserIdValue) {
      return;
    }

    const messages = Array.from(this.element.querySelectorAll('[data-sender-id]'));

    if (messages.length === 0) {
      return;
    }

    const currentUserId = parseInt(this.currentUserIdValue, 10);

    messages.forEach(messageEl => {
      const senderIdAttr = messageEl.getAttribute('data-sender-id');
      if (!senderIdAttr) return;

      const senderId = parseInt(senderIdAttr, 10);
      const isOwnMessage = senderId === currentUserId;

      if (isOwnMessage) {
        messageEl.style.justifyContent = 'flex-end';
        messageEl.classList.remove('justify-start');
        messageEl.classList.add('justify-end');
      } else {
        messageEl.style.justifyContent = 'flex-start';
        messageEl.classList.remove('justify-end');
        messageEl.classList.add('justify-start');
      }

      const messageDiv = messageEl.firstElementChild;
      if (messageDiv) {
        const senderNameDiv = messageDiv.querySelector('.sender-name');

        if (isOwnMessage) {
          messageDiv.classList.remove(
            'bg-gray-100',
            'text-gray-900',
            'dark:bg-gray-800',
            'dark:text-gray-100'
          );
          messageDiv.classList.add('bg-brand-500', 'text-white');
          if (senderNameDiv) {
            senderNameDiv.style.display = 'none';
          }
        } else {
          messageDiv.classList.remove('bg-brand-500', 'text-white');
          messageDiv.classList.add(
            'bg-gray-100',
            'text-gray-900',
            'dark:bg-gray-800',
            'dark:text-gray-100'
          );
          if (senderNameDiv) {
            senderNameDiv.style.display = 'block';
          }
        }
      }
    });
  }

  scrollToBottom() {
    setTimeout(() => {
      this.element.scrollTo({
        top: this.element.scrollHeight,
        behavior: 'smooth',
      });
    }, 100);
  }
}
