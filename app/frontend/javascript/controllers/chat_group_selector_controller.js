import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['button'];

  switchGroup(event) {
    event.preventDefault();
    event.stopPropagation();

    const button = event.currentTarget;
    if (button.disabled) {
      return;
    }

    const selectedGroup = button.dataset.group;
    const chatFormElement = document.querySelector('[data-controller*="chat-form"]');
    const beneficiaryId = chatFormElement?.dataset.beneficiaryId;

    if (!beneficiaryId || !selectedGroup) return;

    const url = new URL(window.location);
    url.searchParams.set('chat_group', selectedGroup);
    url.searchParams.set('tab', 'chat');

    window.location.href = url.toString();
  }
}
