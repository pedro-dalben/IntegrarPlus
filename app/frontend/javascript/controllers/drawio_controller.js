import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['iframe', 'saveIndicator', 'saveStatus', 'versionNotes'];
  static values = {
    flowChartId: Number,
    updateUrl: String,
    exportUrl: String,
    initialData: String,
  };

  connect() {
    // Expor referência global para acesso externo
    window.drawioController = this;

    this.boundHandleMessage = this.handleMessage.bind(this);
    window.addEventListener('message', this.boundHandleMessage);

    this.iframe = this.iframeTarget;
    this.diagramLoaded = false;
    this.currentXml = this.decodeHtml(this.initialDataValue) || this.getEmptyDiagram();
    this.pendingSave = false;
    this.saveAttempts = 0;
    this.isManualExport = false;

    // Verificar se o iframe existe
    if (!this.iframe) {
      console.error('Iframe not found!');
      return;
    }

    this.iframe.addEventListener('load', () => {
      // Aguardar um pouco para o draw.io inicializar completamente
      setTimeout(() => {
        this.loadDiagram();
      }, 2000);
    });

    // Adicionar listener para erro de carregamento
    this.iframe.addEventListener('error', event => {
      console.error('Iframe failed to load:', event);
    });

    // Fallback: tentar carregar após 5 segundos se não carregou
    setTimeout(() => {
      if (!this.diagramLoaded) {
        this.loadDiagram();
      }
    }, 5000);
  }

  disconnect() {
    window.removeEventListener('message', this.boundHandleMessage);
    // Limpar referência global
    if (window.drawioController === this) {
      window.drawioController = null;
    }
  }

  handleMessage(event) {
    if (!event.data || typeof event.data !== 'string') return;

    try {
      const message = JSON.parse(event.data);

      switch (message.event) {
        case 'init':
          this.handleInit();
          break;
        case 'autosave':
        case 'save':
          this.handleSaveEvent(message);
          break;
        case 'export':
          this.handleExport(message);
          break;
        case 'configure':
          this.handleConfigure();
          break;
      }
    } catch (e) {
      console.error('Error parsing message:', e);
    }
  }

  handleInit() {
    this.loadDiagram();
  }

  handleSaveEvent(message) {
    if (message.xml) {
      this.currentXml = message.xml;
    }
  }

  handleExport(message) {
    if (message.data) {
      const format = message.format || 'png';

      // Verificar se é XML válido (começa com <mxfile)
      if (
        format === 'xml' ||
        (typeof message.data === 'string' && message.data.startsWith('<mxfile'))
      ) {
        this.currentXml = message.data;
        if (this.pendingSave) {
          this.pendingSave = false;
          this.saveDiagram();
        }
        return;
      }

      // Se é SVG mas estamos tentando salvar, usar o XML atual
      if (format === 'svg' && this.pendingSave) {
        this.pendingSave = false;
        this.saveDiagramAndSubmit();
        return;
      }

      // Se recebeu dados mas não é XML válido e está tentando salvar, usar XML atual
      if (this.pendingSave && format !== 'xml') {
        this.pendingSave = false;
        this.saveDiagramAndSubmit();
        return;
      }

      // Se não é XML e não é um save pendente, fazer download apenas se for export manual
      if (!this.pendingSave && this.isManualExport) {
        this.downloadFile(message.data, `fluxograma-${this.flowChartIdValue}.${format}`);
      }
    }
  }

  handleConfigure() {
    this.sendMessage({
      action: 'configure',
      config: {
        defaultLibraries: 'general;uml;er;bpmn',
        autosave: 1,
        saveAndExit: false,
      },
    });
  }

  loadDiagram() {
    if (this.diagramLoaded) return;

    const xml = this.currentXml;

    // Verificar se o iframe está pronto
    if (!this.iframe || !this.iframe.contentWindow) {
      console.error('Iframe not ready for loading diagram');
      return;
    }

    this.sendMessage({
      action: 'load',
      xml,
      autosave: 1,
    });

    this.diagramLoaded = true;
  }

  save(event) {
    // Verificar se o evento é do botão de salvar do draw.io
    if (!event.target.closest('[data-action*="drawio#save"]')) {
      return;
    }

    event.preventDefault();

    // Evitar múltiplos saves simultâneos
    if (this.pendingSave) {
      return;
    }

    this.showSaveIndicator();
    this.updateSaveStatus('Solicitando dados do diagrama...');

    this.pendingSave = true;
    this.saveAttempts = 0;

    // Verificar se o iframe está pronto
    if (!this.iframe || !this.iframe.contentWindow) {
      console.error('Iframe not ready for saving');
      this.updateSaveStatus('Erro: Editor não está pronto');
      this.hideSaveIndicator();
      this.pendingSave = false;
      return;
    }

    // Timeout para evitar loop infinito
    this.saveTimeout = setTimeout(() => {
      console.error('Save timeout - forcing save with current data');
      this.pendingSave = false;
      this.saveDiagram();
    }, 10000); // 10 segundos de timeout

    // Aguardar um pouco para garantir que o iframe esteja pronto
    setTimeout(() => {
      this.sendMessage({
        action: 'export',
        format: 'xml',
      });
    }, 500);
  }

  async saveDiagram() {
    try {
      // Limpar timeout se existir
      if (this.saveTimeout) {
        clearTimeout(this.saveTimeout);
        this.saveTimeout = null;
      }

      this.updateSaveStatus('Salvando versão...');

      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;
      const versionNotes = this.hasVersionNotesTarget ? this.versionNotesTarget.value : '';

      const formData = new FormData();
      formData.append('diagram_data', this.currentXml);
      formData.append('version_notes', versionNotes);

      const response = await fetch(this.updateUrlValue, {
        method: 'PATCH',
        headers: {
          'X-CSRF-Token': csrfToken,
          Accept: 'application/json',
        },
        body: formData,
      });

      if (!response.ok) throw new Error('Erro ao salvar');

      // Exportar PNG para thumbnail e enviar em segundo PATCH (best-effort)
      await this.exportThumbnailPNG();

      this.updateSaveStatus('Versão salva com sucesso!');
      this.hideSaveIndicator();
      this.pendingSave = false;

      if (this.hasVersionNotesTarget) {
        this.versionNotesTarget.value = '';
      }

      setTimeout(() => {
        window.location.reload();
      }, 1000);
    } catch (error) {
      console.error('Error saving diagram:', error);
      this.updateSaveStatus('Erro ao salvar. Tente novamente.');
      this.hideSaveIndicator();
      this.pendingSave = false;
    }
  }

  async exportThumbnailPNG() {
    return new Promise(resolve => {
      const onMessage = async event => {
        if (!event.data || typeof event.data !== 'string') return;
        try {
          const msg = JSON.parse(event.data);
          if (msg.event === 'export' && msg.data && msg.format === 'png') {
            window.removeEventListener('message', onMessage);
            try {
              const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;
              const fd = new FormData();
              fd.append('thumbnail_data', msg.data);
              fetch(this.updateUrlValue, {
                method: 'PATCH',
                headers: { 'X-CSRF-Token': csrfToken, Accept: 'application/json' },
                body: fd,
              }).finally(() => resolve());
            } catch (_) {
              resolve();
            }
          }
        } catch (_) {}
      };
      window.addEventListener('message', onMessage);
      this.sendMessage({
        action: 'export',
        format: 'png',
        scale: 1,
        border: 5,
        embedImages: true,
        background: '#ffffff',
      });
      setTimeout(() => {
        window.removeEventListener('message', onMessage);
        resolve();
      }, 4000);
    });
  }

  exportPNG(event) {
    event.preventDefault();
    this.updateSaveStatus('Exportando PNG...');

    // Marcar que é um export manual (não para thumbnail)
    this.isManualExport = true;

    this.sendMessage({
      action: 'export',
      format: 'png',
      embedImages: true,
    });

    setTimeout(() => {
      this.updateSaveStatus('');
      this.isManualExport = false;
    }, 2000);
  }

  exportSVG(event) {
    event.preventDefault();
    this.updateSaveStatus('Exportando SVG...');

    this.sendMessage({
      action: 'export',
      format: 'svg',
      embedImages: true,
    });

    setTimeout(() => {
      this.updateSaveStatus('');
    }, 2000);
  }

  exportPDF(event) {
    event.preventDefault();
    this.updateSaveStatus('Exportando PDF...');

    this.sendMessage({
      action: 'export',
      format: 'pdf',
    });

    setTimeout(() => {
      this.updateSaveStatus('');
    }, 2000);
  }

  sendMessage(message) {
    if (!this.iframe || !this.iframe.contentWindow) {
      console.error('Iframe not ready');
      return;
    }

    this.iframe.contentWindow.postMessage(JSON.stringify(message), '*');
  }

  downloadFile(dataUri, filename) {
    const link = document.createElement('a');
    link.href = dataUri;
    link.download = filename;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);

    this.updateSaveStatus('Download iniciado!');
    setTimeout(() => {
      this.updateSaveStatus('');
    }, 2000);
  }

  showSaveIndicator() {
    if (this.hasSaveIndicatorTarget) {
      this.saveIndicatorTarget.classList.remove('hidden');
    }
  }

  hideSaveIndicator() {
    if (this.hasSaveIndicatorTarget) {
      this.saveIndicatorTarget.classList.add('hidden');
    }
  }

  updateSaveStatus(message) {
    if (this.hasSaveStatusTarget) {
      this.saveStatusTarget.textContent = message;
    }
  }

  decodeHtml(escaped) {
    if (!escaped) return '';
    const txt = document.createElement('textarea');
    txt.innerHTML = escaped;
    return txt.value;
  }

  getEmptyDiagram() {
    return `<mxfile host="embed.diagrams.net" modified="${new Date().toISOString()}" agent="IntegrarPlus" version="1.0.0" etag="" type="embed">
  <diagram name="Page-1" id="page-1">
    <mxGraphModel dx="800" dy="600" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="827" pageHeight="1169" math="0" shadow="0">
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>`;
  }

  saveAndSubmit(event) {
    if (event) {
      event.preventDefault();
    }

    // Evitar múltiplos saves simultâneos
    if (this.pendingSave) {
      return;
    }

    this.showSaveIndicator();
    this.updateSaveStatus('Salvando diagrama e informações...');

    this.pendingSave = true;
    this.saveAttempts = 0;

    // Verificar se o iframe está pronto
    if (!this.iframe || !this.iframe.contentWindow) {
      console.error('Iframe not ready for saving');
      this.updateSaveStatus('Erro: Editor não está pronto');
      this.hideSaveIndicator();
      this.pendingSave = false;
      return;
    }

    // Timeout para evitar loop infinito
    this.saveTimeout = setTimeout(() => {
      console.error('Save timeout - forcing save with current data');
      this.pendingSave = false;
      this.saveDiagramAndSubmit();
    }, 10000); // 10 segundos de timeout

    // Aguardar um pouco para garantir que o iframe esteja pronto
    setTimeout(() => {
      this.sendMessage({
        action: 'export',
        format: 'xml',
      });
    }, 500);
  }

  async saveDiagramAndSubmit() {
    try {
      // Limpar timeout se existir
      if (this.saveTimeout) {
        clearTimeout(this.saveTimeout);
        this.saveTimeout = null;
      }

      this.updateSaveStatus('Salvando diagrama...');

      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;
      const versionNotes = this.hasVersionNotesTarget ? this.versionNotesTarget.value : '';

      const formData = new FormData();
      formData.append('diagram_data', this.currentXml);
      formData.append('version_notes', versionNotes);

      const response = await fetch(this.updateUrlValue, {
        method: 'PATCH',
        headers: {
          'X-CSRF-Token': csrfToken,
          Accept: 'application/json',
        },
        body: formData,
      });

      if (!response.ok) throw new Error('Erro ao salvar diagrama');

      // Exportar PNG para thumbnail e enviar em segundo PATCH (best-effort)
      await this.exportThumbnailPNG();

      this.updateSaveStatus('Diagrama salvo! Salvando informações...');
      this.pendingSave = false;

      // Agora submeter o formulário de informações
      const form = document.getElementById('flow-chart-info-form');
      if (form) {
        // Criar um input hidden para forçar redirecionamento para show
        const redirectInput = document.createElement('input');
        redirectInput.type = 'hidden';
        redirectInput.name = 'redirect_to_show';
        redirectInput.value = 'true';
        form.appendChild(redirectInput);

        // Usar fetch para submeter o formulário e controlar o redirecionamento
        const formData = new FormData(form);
        const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;

        fetch(form.action, {
          method: 'POST',
          headers: {
            'X-CSRF-Token': csrfToken,
            Accept: 'text/html',
          },
          body: formData,
        })
          .then(response => {
            if (response.ok) {
              // Redirecionar para a tela de show
              const showUrl = this.updateUrlValue.replace('/edit', '');
              window.location.href = showUrl;
            } else {
              console.error('Erro ao salvar informações');
              this.updateSaveStatus('Erro ao salvar informações');
              this.hideSaveIndicator();
            }
          })
          .catch(error => {
            console.error('Erro na requisição:', error);
            this.updateSaveStatus('Erro ao salvar informações');
            this.hideSaveIndicator();
          });
      } else {
        console.error('Formulário não encontrado');
        this.updateSaveStatus('Erro: Formulário não encontrado');
        this.hideSaveIndicator();
      }
    } catch (error) {
      console.error('Error saving diagram:', error);
      this.updateSaveStatus('Erro ao salvar. Tente novamente.');
      this.hideSaveIndicator();
      this.pendingSave = false;
    }
  }
}
