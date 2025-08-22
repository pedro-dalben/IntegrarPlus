import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "commentsList"]

  connect() {
    this.hideForm()
  }

  showForm() {
    this.formTarget.classList.remove('hidden')
  }

  hideForm() {
    this.formTarget.classList.add('hidden')
  }

  toggleForm() {
    if (this.formTarget.classList.contains('hidden')) {
      this.showForm()
    } else {
      this.hideForm()
    }
  }

  cancelComment() {
    this.hideForm()
    this.formTarget.querySelector('textarea').value = ''
  }
}

// Funções globais para edição de comentários
window.editComment = function(commentId) {
  // Implementação será feita via Turbo Stream
  console.log('Editando comentário:', commentId)
}

window.cancelEditComment = function(commentId) {
  // Implementação será feita via Turbo Stream
  console.log('Cancelando edição do comentário:', commentId)
}
