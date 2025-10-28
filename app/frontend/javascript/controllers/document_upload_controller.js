import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = [
    'dropZone',
    'fileInfo',
    'fileName',
    'progressContainer',
    'progressBar',
    'progressText',
    'submitButton',
  ];

  static actions = ['submit'];

  connect() {
    this.setupDragAndDrop();
  }

  setupDragAndDrop() {
    this.dropZoneTarget.addEventListener('dragover', e => {
      e.preventDefault();
      this.dropZoneTarget.classList.add('border-blue-400', 'bg-blue-50');
    });

    this.dropZoneTarget.addEventListener('dragleave', e => {
      e.preventDefault();
      if (!this.dropZoneTarget.contains(e.relatedTarget)) {
        this.dropZoneTarget.classList.remove('border-blue-400', 'bg-blue-50');
      }
    });

    this.dropZoneTarget.addEventListener('drop', e => {
      e.preventDefault();
      this.dropZoneTarget.classList.remove('border-blue-400', 'bg-blue-50');

      const { files } = e.dataTransfer;
      if (files.length > 0) {
        this.handleFile(files[0]);
      }
    });
  }

  handleFileSelect(event) {
    const file = event.target.files[0];
    if (file) {
      this.handleFile(file);
    }
  }

  handleFile(file) {
    if (!this.validateFile(file)) {
      return;
    }

    this.showFileInfo(file);
    this.showProgress();
  }

  validateFile(file) {
    const allowedTypes = ['.pdf', '.docx', '.xlsx', '.jpg', '.jpeg', '.png'];
    const maxSize = 50 * 1024 * 1024; // 50MB

    const extension = `.${file.name.split('.').pop().toLowerCase()}`;
    if (!allowedTypes.includes(extension)) {
      alert('Tipo de arquivo não permitido. Use: PDF, DOCX, XLSX, JPG, PNG');
      return false;
    }

    if (file.size > maxSize) {
      alert('Arquivo muito grande. Tamanho máximo: 50MB');
      return false;
    }

    return true;
  }

  showFileInfo(file) {
    this.fileNameTarget.textContent = `${file.name} (${this.formatFileSize(file.size)})`;
    this.fileInfoTarget.classList.remove('hidden');

    const fileInput = this.element.querySelector('input[type="file"]');
    if (fileInput) {
      try {
        const dataTransfer = new DataTransfer();
        dataTransfer.items.add(file);
        fileInput.files = dataTransfer.files;
      } catch (error) {}
    }
  }

  showProgress() {
    this.progressContainerTarget.classList.remove('hidden');
    this.submitButtonTarget.disabled = false;

    this.progressBarTarget.style.width = '100%';
    this.progressTextTarget.textContent = 'Arquivo selecionado e pronto para upload';
  }

  formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return `${parseFloat((bytes / Math.pow(k, i)).toFixed(2))} ${sizes[i]}`;
  }

  submit() {
    this.progressTextTarget.textContent = 'Enviando arquivo...';
    this.progressBarTarget.style.width = '100%';
  }
}
