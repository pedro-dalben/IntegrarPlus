import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dropZone", "fileInfo", "fileName", "progressContainer", "progressBar", "progressText", "submitButton"]

  connect() {
    this.setupDragAndDrop()
  }

  setupDragAndDrop() {
    this.dropZoneTarget.addEventListener('dragover', (e) => {
      e.preventDefault()
      this.dropZoneTarget.classList.add('border-blue-400', 'bg-blue-50')
    })

    this.dropZoneTarget.addEventListener('dragleave', (e) => {
      e.preventDefault()
      this.dropZoneTarget.classList.remove('border-blue-400', 'bg-blue-50')
    })

    this.dropZoneTarget.addEventListener('drop', (e) => {
      e.preventDefault()
      this.dropZoneTarget.classList.remove('border-blue-400', 'bg-blue-50')
      
      const files = e.dataTransfer.files
      if (files.length > 0) {
        this.handleFile(files[0])
      }
    })
  }

  handleFileSelect(event) {
    const file = event.target.files[0]
    if (file) {
      this.handleFile(file)
    }
  }

  handleFile(file) {
    if (!this.validateFile(file)) {
      return
    }

    this.showFileInfo(file)
    this.simulateProgress()
  }

  validateFile(file) {
    const allowedTypes = ['.pdf', '.docx', '.xlsx', '.jpg', '.jpeg', '.png']
    const maxSize = 50 * 1024 * 1024 // 50MB

    const extension = '.' + file.name.split('.').pop().toLowerCase()
    if (!allowedTypes.includes(extension)) {
      alert('Tipo de arquivo não permitido. Use: PDF, DOCX, XLSX, JPG, PNG')
      return false
    }

    if (file.size > maxSize) {
      alert('Arquivo muito grande. Tamanho máximo: 50MB')
      return false
    }

    return true
  }

  showFileInfo(file) {
    this.fileNameTarget.textContent = `${file.name} (${this.formatFileSize(file.size)})`
    this.fileInfoTarget.classList.remove('hidden')
  }

  simulateProgress() {
    this.progressContainerTarget.classList.remove('hidden')
    this.submitButtonTarget.disabled = true

    let progress = 0
    const interval = setInterval(() => {
      progress += Math.random() * 15
      if (progress >= 100) {
        progress = 100
        clearInterval(interval)
        this.submitButtonTarget.disabled = false
      }
      
      this.progressBarTarget.style.width = `${progress}%`
      this.progressTextTarget.textContent = `${Math.round(progress)}%`
    }, 200)
  }

  formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes'
    const k = 1024
    const sizes = ['Bytes', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
  }
}
