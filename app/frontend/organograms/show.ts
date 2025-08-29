import { Diagram } from 'dhx-suite';
import jsPDF from 'jspdf';
import html2canvas from 'html2canvas';

interface OrganogramData {
  name: string;
  nodes: any[];
  links: any[];
  settings: any;
  published_at?: string;
}

let diagram: any = null;
let organogramId: number;

export function initOrganogramViewer(data: OrganogramData, id: number) {
  organogramId = id;

  const container = document.getElementById('orgchart-view');
  if (!container) {
    console.error('Container da visualização não encontrado');
    return;
  }

  // Inicializar o DHX Diagram em modo somente leitura
  diagram = new Diagram(container, {
    type: 'org',
    defaultShapeType: 'card',
    toolbar: false,
    // Desabilitar edição
    editor: false
  });

  // Carregar dados
  loadDiagramData(data);

  // Configurar event listeners
  setupEventListeners();

  // Desabilitar interações de edição
  disableEditing();
}

function loadDiagramData(data: OrganogramData) {
  if (!diagram) return;

  try {
    // Limpar dados existentes
    diagram.data.removeAll();

    // Carregar nós
    if (data.nodes && data.nodes.length > 0) {
      data.nodes.forEach((node: any) => {
        diagram.data.add({
          id: node.id || generateId(),
          text: node.text || node.name || '',
          title: node.title || node.role_title || '',
          parent: node.parent || node.pid || undefined,
          type: 'card',
          ...node
        });
      });
    } else {
      // Exibir mensagem se não houver dados
      const container = document.getElementById('orgchart-view');
      if (container) {
        container.innerHTML = `
          <div class="flex items-center justify-center h-full text-gray-500 dark:text-gray-400">
            <div class="text-center">
              <svg class="mx-auto h-12 w-12 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"/>
              </svg>
              <p>Nenhum organograma para exibir</p>
              <p class="text-sm">Use o editor para adicionar nós</p>
            </div>
          </div>
        `;
      }
      return;
    }

    // Aplicar configurações
    if (data.settings) {
      applyDiagramSettings(data.settings);
    }

    // Ajustar visualização
    setTimeout(() => {
      diagram.zoomToFit();
    }, 100);

  } catch (error) {
    console.error('Erro ao carregar dados do diagrama:', error);
    showToast('Erro ao carregar organograma', 'error');
  }
}

function setupEventListeners() {
  // Botão de exportar PDF (se existir na página)
  const exportPdfBtn = document.getElementById('export-pdf-btn');
  if (exportPdfBtn) {
    exportPdfBtn.addEventListener('click', exportToPdf);
  }

  // Eventos de seleção para mostrar informações do nó
  if (diagram) {
    diagram.events.on('itemSelect', (id: string) => {
      showNodeInfo(id);
    });

    diagram.events.on('itemUnselect', () => {
      hideNodeInfo();
    });
  }
}

function disableEditing() {
  if (!diagram) return;

  try {
    // Desabilitar todas as interações de edição
    diagram.config.editor = false;

    // Remover toolbar se existir
    if (diagram.toolbar) {
      diagram.toolbar.hide();
    }

    // Prevenir ações de contexto
    diagram.events.on('itemContextMenu', (e: Event) => {
      e.preventDefault();
      return false;
    });

    // Prevenir drag and drop
    diagram.events.on('beforeItemMove', () => false);
    diagram.events.on('beforeItemAdd', () => false);
    diagram.events.on('beforeItemRemove', () => false);

  } catch (error) {
    console.warn('Erro ao desabilitar edição:', error);
  }
}

function showNodeInfo(nodeId: string) {
  if (!diagram) return;

  const item = diagram.data.getItem(nodeId);
  if (!item) return;

  // Criar tooltip ou modal com informações do nó
  const existingTooltip = document.getElementById('node-info-tooltip');
  if (existingTooltip) {
    existingTooltip.remove();
  }

  const tooltip = document.createElement('div');
  tooltip.id = 'node-info-tooltip';
  tooltip.className = 'fixed z-50 bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg shadow-lg p-4 max-w-sm';

  const email = item.data?.email ? `<div class="text-sm text-gray-600 dark:text-gray-400">${item.data.email}</div>` : '';
  const phone = item.data?.phone ? `<div class="text-sm text-gray-600 dark:text-gray-400">${item.data.phone}</div>` : '';
  const department = item.data?.department ? `<div class="text-sm font-medium text-gray-700 dark:text-gray-300 mt-2">${item.data.department}</div>` : '';

  tooltip.innerHTML = `
    <div class="space-y-2">
      <div>
        <div class="font-semibold text-gray-900 dark:text-white">${item.text || 'Sem nome'}</div>
        <div class="text-sm text-blue-600 dark:text-blue-400">${item.title || 'Sem título'}</div>
      </div>
      ${department}
      ${email}
      ${phone}
    </div>
  `;

  document.body.appendChild(tooltip);

  // Posicionar o tooltip próximo ao cursor
  document.addEventListener('mousemove', updateTooltipPosition);
}

function hideNodeInfo() {
  const tooltip = document.getElementById('node-info-tooltip');
  if (tooltip) {
    tooltip.remove();
  }
  document.removeEventListener('mousemove', updateTooltipPosition);
}

function updateTooltipPosition(e: MouseEvent) {
  const tooltip = document.getElementById('node-info-tooltip');
  if (!tooltip) return;

  const offset = 10;
  let x = e.clientX + offset;
  let y = e.clientY + offset;

  // Verificar se o tooltip sai da tela
  const rect = tooltip.getBoundingClientRect();
  if (x + rect.width > window.innerWidth) {
    x = e.clientX - rect.width - offset;
  }
  if (y + rect.height > window.innerHeight) {
    y = e.clientY - rect.height - offset;
  }

  tooltip.style.left = `${x}px`;
  tooltip.style.top = `${y}px`;
}

async function exportToPdf() {
  if (!diagram) return;

  try {
    showToast('Gerando PDF...', 'info');

    // Ajustar o diagrama para caber na tela
    diagram.zoomToFit();

    // Aguardar um pouco para o diagrama se ajustar
    await new Promise(resolve => setTimeout(resolve, 500));

    const container = document.getElementById('orgchart-view');
    if (!container) throw new Error('Container não encontrado');

    // Capturar o canvas
    const canvas = await html2canvas(container, {
      scale: 2,
      useCORS: true,
      backgroundColor: '#ffffff',
      height: container.scrollHeight,
      width: container.scrollWidth
    });

    // Criar PDF
    const pdf = new jsPDF({
      orientation: 'landscape',
      unit: 'pt',
      format: 'a4'
    });

    const imgData = canvas.toDataURL('image/png');
    const pdfWidth = pdf.internal.pageSize.getWidth();
    const pdfHeight = pdf.internal.pageSize.getHeight();

    const canvasWidth = canvas.width;
    const canvasHeight = canvas.height;

    // Calcular proporção mantendo aspect ratio
    const ratio = Math.min(pdfWidth / canvasWidth, pdfHeight / canvasHeight);
    const imgWidth = canvasWidth * ratio;
    const imgHeight = canvasHeight * ratio;

    // Centralizar a imagem
    const x = (pdfWidth - imgWidth) / 2;
    const y = (pdfHeight - imgHeight) / 2;

    // Se a imagem for muito alta, paginar
    if (imgHeight > pdfHeight) {
      let currentY = 0;
      const pageHeight = pdfHeight;
      const pageRatio = pageHeight / imgHeight;
      const pageImgHeight = pageHeight;
      const pageImgWidth = imgWidth * pageRatio;

      while (currentY < canvasHeight) {
        const sourceY = currentY;
        const sourceHeight = Math.min(canvasHeight / ratio, canvasHeight - currentY);

        if (currentY > 0) {
          pdf.addPage();
        }

        // Criar canvas temporário para esta página
        const tempCanvas = document.createElement('canvas');
        const tempCtx = tempCanvas.getContext('2d');
        tempCanvas.width = canvasWidth;
        tempCanvas.height = sourceHeight * ratio;

        if (tempCtx) {
          tempCtx.drawImage(canvas, 0, sourceY * ratio, canvasWidth, sourceHeight * ratio, 0, 0, canvasWidth, sourceHeight * ratio);
          const tempImgData = tempCanvas.toDataURL('image/png');
          pdf.addImage(tempImgData, 'PNG', x, 0, pageImgWidth, pageImgHeight);
        }

        currentY += sourceHeight;
      }
    } else {
      pdf.addImage(imgData, 'PNG', x, y, imgWidth, imgHeight);
    }

    // Adicionar metadados
    pdf.setProperties({
      title: `Organograma ${organogramId}`,
      subject: 'Organograma organizacional',
      creator: 'Sistema IntegrarPlus',
      keywords: 'organograma, organização, estrutura'
    });

    // Salvar PDF
    pdf.save(`organograma-${organogramId}.pdf`);
    showToast('PDF exportado com sucesso!', 'success');

  } catch (error) {
    console.error('Erro ao exportar PDF:', error);
    showToast('Erro ao exportar PDF', 'error');
  }
}

function applyDiagramSettings(settings: any) {
  if (!diagram || !settings) return;

  try {
    if (settings.zoom) {
      diagram.zoom = settings.zoom;
    }
  } catch (error) {
    console.warn('Erro ao aplicar configurações:', error);
  }
}

function generateId(): string {
  return 'node_' + Math.random().toString(36).substr(2, 9);
}

function showToast(message: string, type: 'success' | 'error' | 'info' = 'info') {
  // Criar container de toast se não existir
  let container = document.getElementById('toast-container');
  if (!container) {
    container = document.createElement('div');
    container.id = 'toast-container';
    container.className = 'fixed top-4 right-4 z-50 space-y-2';
    document.body.appendChild(container);
  }

  const colors = {
    success: 'bg-green-500 text-white',
    error: 'bg-red-500 text-white',
    info: 'bg-blue-500 text-white'
  };

  const icons = {
    success: '✓',
    error: '✗',
    info: 'ℹ'
  };

  const toast = document.createElement('div');
  toast.className = `${colors[type]} px-4 py-3 rounded-lg shadow-lg flex items-center gap-3 transform transition-all duration-300 translate-x-full opacity-0`;
  toast.innerHTML = `
    <span class="text-lg">${icons[type]}</span>
    <span class="text-sm font-medium">${message}</span>
  `;

  container.appendChild(toast);

  // Animar entrada
  setTimeout(() => {
    toast.classList.remove('translate-x-full', 'opacity-0');
  }, 10);

  // Remover após 3 segundos
  setTimeout(() => {
    toast.classList.add('translate-x-full', 'opacity-0');
    setTimeout(() => {
      if (container.contains(toast)) {
        container.removeChild(toast);
      }
    }, 300);
  }, 3000);
}
