import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['form', 'content', 'editButton', 'cancelButton'];

  connect() {
    this.setupEventListeners();
  }

  setupEventListeners() {
    this.editButtonTargets.forEach(button => {
      button.addEventListener('click', e => {
        e.preventDefault();
        this.editComment(button.dataset.commentId);
      });
    });

    this.cancelButtonTargets.forEach(button => {
      button.addEventListener('click', e => {
        e.preventDefault();
        this.cancelEdit(button.dataset.commentId);
      });
    });
  }

  editComment(commentId) {
    const form = this.formTargets.find(form => form.dataset.commentId === commentId);
    const content = this.contentTargets.find(content => content.dataset.commentId === commentId);
    const editButton = this.editButtonTargets.find(
      button => button.dataset.commentId === commentId
    );
    const cancelButton = this.cancelButtonTargets.find(
      button => button.dataset.commentId === commentId
    );

    if (form && content && editButton && cancelButton) {
      form.classList.remove('hidden');
      content.classList.add('hidden');
      editButton.classList.add('hidden');
      cancelButton.classList.remove('hidden');
    }
  }

  cancelEdit(commentId) {
    const form = this.formTargets.find(form => form.dataset.commentId === commentId);
    const content = this.contentTargets.find(content => content.dataset.commentId === commentId);
    const editButton = this.editButtonTargets.find(
      button => button.dataset.commentId === commentId
    );
    const cancelButton = this.cancelButtonTargets.find(
      button => button.dataset.commentId === commentId
    );

    if (form && content && editButton && cancelButton) {
      form.classList.add('hidden');
      content.classList.remove('hidden');
      editButton.classList.remove('hidden');
      cancelButton.classList.add('hidden');
    }
  }
}
