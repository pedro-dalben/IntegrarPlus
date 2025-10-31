import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['input', 'messagesContainer'];

  connect() {
    this.setupMessageStyling();
    this.setupTurboStreamListener();
    this.setupReadTracking();
    this.setupEnterKeyHandler();

    setTimeout(() => {
      this.scrollToFirstUnread();
    }, 100);
  }

  disconnect() {
    if (this.turboStreamObserver) {
      this.turboStreamObserver.disconnect();
    }
    if (this.readObserver) {
      this.readObserver.disconnect();
    }
    if (this.readTrackingObserver) {
      this.readTrackingObserver.disconnect();
    }
    if (this.hasInputTarget) {
      this.inputTarget.removeEventListener('keydown', this.handleKeyDown.bind(this));
    }
  }

  setupEnterKeyHandler() {
    const form = this.element.querySelector('form');
    if (!form) return;

    const textarea = form.querySelector('textarea');
    if (!textarea) return;

    textarea.addEventListener('keydown', event => {
      if (event.key === 'Enter' && !event.shiftKey) {
        event.preventDefault();
        event.stopPropagation();

        const content = textarea.value.trim();
        if (content) {
          form.requestSubmit();
        }
      }
    });
  }

  handleKeyDown(event) {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault();
      event.stopPropagation();
      const form = this.element.querySelector('form');
      if (form && this.hasInputTarget && this.inputTarget.value.trim()) {
        form.requestSubmit();
      }
    }
  }

  setupMessageStyling() {
    const currentUserIdAttr = this.element.getAttribute('data-current-user-id');
    const currentUserId = currentUserIdAttr ? String(currentUserIdAttr).trim() : '';

    if (!currentUserId) {
      console.warn(
        'chat-form: currentUserId não encontrado. Atributo:',
        this.element.getAttribute('data-current-user-id')
      );
      return;
    }

    const beneficiaryId = this.element.dataset.beneficiaryId;
    const selectedGroup = this.element.dataset.selectedGroup || 'professionals_only';

    const messagesContainer = this.hasMessagesContainerTarget
      ? this.messagesContainerTarget.querySelector(
          `#beneficiary_chat_messages_${beneficiaryId}_${selectedGroup}`
        )
      : this.element.querySelector(`#beneficiary_chat_messages_${beneficiaryId}_${selectedGroup}`);

    if (!messagesContainer) {
      console.warn('chat-form: messagesContainer não encontrado');
      return;
    }

    const messages = messagesContainer.querySelectorAll('[data-message-user-id]');

    messages.forEach(messageEl => {
      const messageUserIdAttr = messageEl.getAttribute('data-message-user-id');
      const messageUserId = messageUserIdAttr ? String(messageUserIdAttr).trim() : '';
      const isOwnMessage = messageUserId && currentUserId && messageUserId === currentUserId;

      if (isOwnMessage) {
        messageEl.style.marginLeft = 'auto';
        messageEl.style.marginRight = '0';
        messageEl.style.width = 'max-content';
        messageEl.classList.add('own-message');

        const wrapper = messageEl.firstElementChild;
        if (wrapper) {
          wrapper.style.flexDirection = 'row-reverse';
          wrapper.classList.add('flex-row-reverse');
        }
        const bubble = messageEl.querySelector('.message-bubble');
        if (bubble) {
          bubble.classList.remove('rounded-tl-sm', 'bg-gray-100', 'dark:bg-white/5');
          bubble.classList.add('rounded-tr-sm', 'bg-brand-500');
          const text = bubble.querySelector('p');
          if (text) {
            text.classList.remove('text-gray-800', 'dark:text-white/90');
            text.classList.add('text-white');
          }
        }
        const timestampContainer = messageEl.querySelector('.message-timestamp')?.parentElement;
        if (timestampContainer) {
          timestampContainer.style.textAlign = 'right';
        }
        const timestamp = messageEl.querySelector('.message-timestamp');
        if (timestamp) {
          timestamp.classList.add('text-right');
        }
      } else {
        messageEl.style.marginLeft = '0';
        messageEl.style.marginRight = 'auto';
        messageEl.style.width = '';
        messageEl.classList.remove('own-message');

        const wrapper = messageEl.firstElementChild;
        if (wrapper) {
          wrapper.style.flexDirection = '';
          wrapper.classList.remove('flex-row-reverse');
        }
        const bubble = messageEl.querySelector('.message-bubble');
        if (bubble) {
          bubble.classList.remove('rounded-tr-sm', 'bg-brand-500');
          bubble.classList.add('rounded-tl-sm', 'bg-gray-100', 'dark:bg-white/5');
          const text = bubble.querySelector('p');
          if (text) {
            text.classList.remove('text-white');
            text.classList.add('text-gray-800', 'dark:text-white/90');
          }
        }
        const timestampContainer = messageEl.querySelector('.message-timestamp')?.parentElement;
        if (timestampContainer) {
          timestampContainer.style.textAlign = '';
        }
        const timestamp = messageEl.querySelector('.message-timestamp');
        if (timestamp) {
          timestamp.classList.remove('text-right');
        }
      }
    });
  }

  setupTurboStreamListener() {
    const messagesContainer = this.hasMessagesContainerTarget ? this.messagesContainerTarget : null;
    if (!messagesContainer) return;

    const beneficiaryId = this.element.dataset.beneficiaryId;
    const selectedGroup = this.element.dataset.selectedGroup || 'professionals_only';
    const messagesList = messagesContainer.querySelector(
      `#beneficiary_chat_messages_${beneficiaryId}_${selectedGroup}`
    );
    if (!messagesList) return;

    let debounceTimeout;
    this.turboStreamObserver = new MutationObserver(mutations => {
      const hasNewMessages = mutations.some(mutation =>
        Array.from(mutation.addedNodes).some(
          node => node.nodeType === 1 && node.hasAttribute && node.hasAttribute('data-message-id')
        )
      );

      const hasUpdatedMessages = mutations.some(mutation =>
        Array.from(mutation.addedNodes).some(
          node =>
            node.nodeType === 1 &&
            ((node.hasAttribute && node.hasAttribute('data-message-id')) ||
              (node.querySelector && node.querySelector('[data-message-id]')))
        )
      );

      if (hasNewMessages) {
        clearTimeout(debounceTimeout);
        debounceTimeout = setTimeout(() => {
          this.scrollToBottom();
          this.setupMessageStyling();
        }, 50);
      }

      if (hasUpdatedMessages) {
        clearTimeout(debounceTimeout);
        debounceTimeout = setTimeout(() => {
          this.setupMessageStyling();
          // Reaplicar tracking de leitura após atualização
          this.updateReadStatus();
          if (this.readObserver) {
            // Re-observar mensagens atualizadas
            const messages = messagesList.querySelectorAll('[data-message-id]');
            messages.forEach(message => {
              if (!message.dataset.observing) {
                this.readObserver.observe(message);
                message.dataset.observing = 'true';
              }
            });
          }
        }, 100);
      }
    });

    this.turboStreamObserver.observe(messagesList, {
      childList: true,
      subtree: true,
      attributes: true,
      attributeFilter: ['data-read-status'],
    });
  }

  resetForm(event) {
    if (this.hasInputTarget && event.detail.success !== false) {
      this.inputTarget.value = '';
      this.inputTarget.style.height = 'auto';

      const autoResizeEvent = new Event('input', { bubbles: true });
      this.inputTarget.dispatchEvent(autoResizeEvent);
    }

    setTimeout(() => {
      this.scrollToBottom();
      this.setupMessageStyling();
    }, 150);
  }

  scrollToBottom() {
    if (this.hasMessagesContainerTarget) {
      const beneficiaryId = this.element.dataset.beneficiaryId;
      const selectedGroup = this.element.dataset.selectedGroup || 'professionals_only';
      const messagesList = this.messagesContainerTarget.querySelector(
        `#beneficiary_chat_messages_${beneficiaryId}_${selectedGroup}`
      );

      if (messagesList && messagesList.offsetHeight > 0) {
        this.messagesContainerTarget.scrollTo({
          top: this.messagesContainerTarget.scrollHeight,
          behavior: 'smooth',
        });
      }
    }
  }

  scrollToFirstUnread() {
    const firstUnreadId = this.element.dataset.firstUnreadId;
    if (!firstUnreadId) {
      this.scrollToBottom();
      return;
    }

    const beneficiaryId = this.element.dataset.beneficiaryId;
    const selectedGroup = this.element.dataset.selectedGroup || 'professionals_only';
    const messagesContainer = this.hasMessagesContainerTarget
      ? this.messagesContainerTarget.querySelector(
          `#beneficiary_chat_messages_${beneficiaryId}_${selectedGroup}`
        )
      : null;

    const firstUnreadMessage = messagesContainer?.querySelector(
      `[data-message-id="${firstUnreadId}"]`
    );
    if (firstUnreadMessage && this.hasMessagesContainerTarget) {
      const container = this.messagesContainerTarget;
      const messageTop = firstUnreadMessage.offsetTop - container.offsetTop - 100;

      container.scrollTo({
        top: messageTop,
        behavior: 'smooth',
      });

      firstUnreadMessage.classList.add('animate-pulse');
      setTimeout(() => {
        firstUnreadMessage.classList.remove('animate-pulse');
      }, 2000);
    } else {
      this.scrollToBottom();
    }
  }

  updateReadStatus() {
    // Atualizar status de leitura após broadcast
    const messagesContainer = this.hasMessagesContainerTarget ? this.messagesContainerTarget : null;
    if (!messagesContainer) return;

    const messages = messagesContainer.querySelectorAll('[data-message-id]');
    const currentUserId = this.element.dataset.currentUserId;

    messages.forEach(message => {
      const messageUserId = message.dataset.messageUserId;
      const isOwnMessage = messageUserId && currentUserId && messageUserId === currentUserId;

      if (!isOwnMessage) {
        // Para mensagens de outros usuários, verificar se foram lidas
        // Fazendo uma requisição AJAX para verificar o status
        const messageId = message.dataset.messageId;
        if (messageId && message.dataset.readStatus === 'unread') {
          // Será verificado pelo IntersectionObserver
        }
      }
    });
  }

  setupReadTracking() {
    if (!this.hasMessagesContainerTarget) return;

    const beneficiaryId = this.element.dataset.beneficiaryId;
    if (!beneficiaryId) return;
    const selectedGroup = this.element.dataset.selectedGroup || 'professionals_only';

    const container = this.messagesContainerTarget;
    const messagesContainer = container.querySelector(
      `#beneficiary_chat_messages_${beneficiaryId}_${selectedGroup}`
    );
    if (!messagesContainer) return;

    const readMessages = new Set();

    const markAsRead = messageId => {
      if (readMessages.has(messageId)) return;

      const messageEl = this.element.querySelector(`[data-message-id="${messageId}"]`);
      if (!messageEl) return;

      const readStatus = messageEl.dataset.readStatus;
      if (readStatus === 'read') return;

      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;
      if (!csrfToken) return;

      fetch(`/admin/beneficiaries/${beneficiaryId}/chat_messages/${messageId}/mark_as_read`, {
        method: 'POST',
        headers: {
          'X-CSRF-Token': csrfToken,
          Accept: 'application/json',
          'Content-Type': 'application/json',
        },
        credentials: 'same-origin',
      })
        .then(() => {
          messageEl.dataset.readStatus = 'read';
          messageEl.classList.remove('unread-message');
          readMessages.add(messageId);

          // Atualizar estilo após marcar como lida
          this.setupMessageStyling();
        })
        .catch(err => {
          console.warn('Erro ao marcar mensagem como lida:', err);
        });
    };

    const intersectionObserver = new IntersectionObserver(
      entries => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            const messageId = entry.target.dataset.messageId;
            if (messageId && entry.target.dataset.readStatus === 'unread') {
              markAsRead(messageId);
            }
          }
        });
      },
      {
        root: container,
        rootMargin: '0px -20px 0px -20px',
        threshold: [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0],
      }
    );

    const observeMessages = () => {
      const messages = messagesContainer.querySelectorAll('[data-message-id]');
      messages.forEach(message => {
        if (!message.dataset.observing) {
          intersectionObserver.observe(message);
          message.dataset.observing = 'true';
        }
      });
    };

    observeMessages();

    // Função auxiliar para verificar se mensagem está visível
    const checkMessageVisibility = message => {
      const rect = message.getBoundingClientRect();
      const containerRect = container.getBoundingClientRect();

      // Verifica se a mensagem está totalmente ou parcialmente visível no container
      const isFullyVisible = rect.top >= containerRect.top && rect.bottom <= containerRect.bottom;
      const isPartiallyVisible = rect.top < containerRect.bottom && rect.bottom > containerRect.top;

      return (isFullyVisible || isPartiallyVisible) && rect.height > 0;
    };

    // Verificar mensagens já visíveis imediatamente (com múltiplas tentativas)
    const checkVisibleMessages = () => {
      const visibleMessages = messagesContainer.querySelectorAll('[data-message-id]');
      visibleMessages.forEach(message => {
        const messageId = message.dataset.messageId;
        if (messageId && message.dataset.readStatus === 'unread') {
          if (checkMessageVisibility(message)) {
            markAsRead(messageId);
          }
        }
      });
    };

    // Verificar imediatamente
    checkVisibleMessages();

    // Verificar novamente após um delay (para garantir que o scroll está completo)
    setTimeout(checkVisibleMessages, 300);
    setTimeout(checkVisibleMessages, 800);

    const readTrackingObserver = new MutationObserver(() => {
      observeMessages();

      // Verificar novamente mensagens visíveis após mudanças
      setTimeout(() => {
        const visibleMessages = messagesContainer.querySelectorAll('[data-message-id]');
        visibleMessages.forEach(message => {
          const messageId = message.dataset.messageId;
          if (messageId && message.dataset.readStatus === 'unread') {
            if (checkMessageVisibility(message)) {
              markAsRead(messageId);
            }
          }
        });
      }, 100);
    });

    readTrackingObserver.observe(messagesContainer, {
      childList: true,
      subtree: true,
    });

    // Observar mudanças de scroll para verificar mensagens visíveis
    let scrollTimeout;
    const handleScroll = () => {
      clearTimeout(scrollTimeout);
      scrollTimeout = setTimeout(() => {
        const visibleMessages = messagesContainer.querySelectorAll('[data-message-id]');
        visibleMessages.forEach(message => {
          const messageId = message.dataset.messageId;
          if (messageId && message.dataset.readStatus === 'unread') {
            if (checkMessageVisibility(message)) {
              markAsRead(messageId);
            }
          }
        });
      }, 150);
    };

    container.addEventListener('scroll', handleScroll, { passive: true });

    // Verificar também quando o scroll chega ao final
    container.addEventListener(
      'scrollend',
      () => {
        checkVisibleMessages();
      },
      { passive: true }
    );

    this.readObserver = intersectionObserver;
    this.readTrackingObserver = readTrackingObserver;
  }
}
