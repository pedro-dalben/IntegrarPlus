import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview"]

  connect() {
    this.inputTarget.addEventListener('change', this.handleFileSelect.bind(this))
  }

  disconnect() {
    this.inputTarget.removeEventListener('change', this.handleFileSelect.bind(this))
  }

  handleFileSelect(event) {
    const file = event.target.files[0]
    if (file && file.type.startsWith('image/')) {
      this.previewFile(file)
      this.uploadFile(file)
    }
  }

  previewFile(file) {
    const reader = new FileReader()
    reader.onload = (e) => {
      if (this.hasPreviewTarget) {
        this.previewTarget.src = e.target.result
        this.previewTarget.style.display = 'block'
      }
    }
    reader.readAsDataURL(file)
  }

  uploadFile(file) {
    const formData = new FormData()
    formData.append('user[avatar]', file)

    fetch('/avatar', {
      method: 'PATCH',
      body: formData,
      headers: {
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        this.showNotification('Avatar atualizado com sucesso!', 'success')
      } else {
        this.showNotification('Erro ao atualizar avatar.', 'error')
      }
    })
    .catch(error => {
      console.error('Error:', error)
      this.showNotification('Erro ao atualizar avatar.', 'error')
    })
  }

  showNotification(message, type) {
    const event = new CustomEvent('show-notification', {
      detail: { message, type }
    })
    document.dispatchEvent(event)
  }
}
