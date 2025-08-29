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

interface EditorConfig {
  organogramId: number;
  updateUrl: string;
  exportJsonUrl: string;
}

let diagram: any = null;
let editorConfig: EditorConfig;
let autoSaveTimeout: NodeJS.Timeout | null = null;
let isUnsaved = false;

export function initOrganogramEditor(data: OrganogramData, config: EditorConfig) {
  editorConfig = config;

  const container = document.getElementById('orgchart-editor');
  if (!container) {
    console.error('Container do editor não encontrado');
    return;
  }

  // Inicializar o DHX Diagram
  diagram = new Diagram(container, {
    type: 'org',
    defaultShapeType: 'card'
  });

  // Carregar dados
  loadDiagramData(data);

  // Configurar event listeners
  setupEventListeners();

  // Configurar auto-save
  setupAutoSave();

  showToast('Editor carregado com sucesso!', 'success');
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
      // Criar nó raiz padrão se não houver dados
      diagram.data.add({
        id: 'root',
        text: 'Organização',
        title: 'Raiz',
        type: 'card'
      });
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
    showToast('Erro ao carregar dados do organograma', 'error');
  }
}

function setupEventListeners() {
  if (!diagram) return;

  // Eventos do diagrama
  diagram.events.on('afterAdd', () => {
    markAsUnsaved();
  });

  diagram.events.on('afterRemove', () => {
    markAsUnsaved();
  });

  diagram.events.on('afterUpdate', () => {
    markAsUnsaved();
  });

  diagram.events.on('itemSelect', (id: string) => {
    showNodeProperties(id);
  });

  diagram.events.on('itemUnselect', () => {
    hideNodeProperties();
  });

  // Botões de controle
  const saveBtn = document.getElementById('save-btn');
  if (saveBtn) {
    saveBtn.addEventListener('click', () => {
      saveDiagram(true);
    });
  }

  const zoomInBtn = document.getElementById('zoom-in-btn');
  if (zoomInBtn) {
    zoomInBtn.addEventListener('click', () => {
      diagram.zoomIn();
    });
  }

  const zoomOutBtn = document.getElementById('zoom-out-btn');
  if (zoomOutBtn) {
    zoomOutBtn.addEventListener('click', () => {
      diagram.zoomOut();
    });
  }

  const fitBtn = document.getElementById('fit-btn');
  if (fitBtn) {
    fitBtn.addEventListener('click', () => {
      diagram.zoomToFit();
    });
  }

  const exportJsonBtn = document.getElementById('export-json-btn');
  if (exportJsonBtn) {
    exportJsonBtn.addEventListener('click', exportToJson);
  }

  const exportPdfBtn = document.getElementById('export-pdf-btn');
  if (exportPdfBtn) {
    exportPdfBtn.addEventListener('click', exportToPdf);
  }

  // Formulário de informações básicas
  const nameInput = document.querySelector('#organogram_name') as HTMLInputElement;
  if (nameInput) {
    nameInput.addEventListener('input', () => {
      markAsUnsaved();
    });
  }

  // Atalhos de teclado
  document.addEventListener('keydown', (e) => {
    if ((e.ctrlKey || e.metaKey) && e.key === 's') {
      e.preventDefault();
      saveDiagram(true);
    }

    if (e.key === 'Delete') {
      const selectedId = diagram.selection.getId();
      if (selectedId) {
        if (confirm('Deseja remover este nó?')) {
          diagram.data.remove(selectedId);
        }
      }
    }
  });
}

function setupAutoSave() {
  // Auto-save a cada 800ms quando houver mudanças
  setInterval(() => {
    if (isUnsaved) {
      saveDiagram(false);
    }
  }, 800);
}

function markAsUnsaved() {
  isUnsaved = true;

  const saveBtn = document.getElementById('save-btn');
  if (saveBtn) {
    saveBtn.classList.add('bg-orange-600', 'hover:bg-orange-700');
    saveBtn.classList.remove('bg-blue-600', 'hover:bg-blue-700');
  }
}

function markAsSaved() {
  isUnsaved = false;

  const saveBtn = document.getElementById('save-btn');
  if (saveBtn) {
    saveBtn.classList.remove('bg-orange-600', 'hover:bg-orange-700');
    saveBtn.classList.add('bg-blue-600', 'hover:bg-blue-700');
  }
}

async function saveDiagram(showNotification = true) {
  if (!diagram || !isUnsaved) return;

  try {
    // Mostrar indicador de salvamento
    const saveBtn = document.getElementById('save-btn');
    const saveText = saveBtn?.querySelector('.save-text');
    const savingText = saveBtn?.querySelector('.saving-text');

    if (saveText && savingText) {
      saveText.classList.add('hidden');
      savingText.classList.remove('hidden');
    }

    // Coletar dados do diagrama
    const nodes: any[] = [];
    diagram.data.eachItem((item: any) => {
      nodes.push({
        id: item.id,
        text: item.text,
        title: item.title,
        parent: item.parent,
        ...item
      });
    });

    // Coletar dados do formulário
    const nameInput = document.querySelector('#organogram_name') as HTMLInputElement;
    const formData = {
      organogram: {
        name: nameInput?.value || '',
        data: {
          nodes: nodes,
          links: []
        },
        settings: getCurrentSettings()
      }
    };

    // Enviar para o servidor
    const response = await fetch(editorConfig.updateUrl, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': getCSRFToken()
      },
      body: JSON.stringify(formData)
    });

    if (response.ok) {
      markAsSaved();
      if (showNotification) {
        showToast('Organograma salvo com sucesso!', 'success');
      }
    } else {
      throw new Error('Erro ao salvar');
    }

  } catch (error) {
    console.error('Erro ao salvar:', error);
    showToast('Erro ao salvar organograma', 'error');
  } finally {
    // Restaurar texto do botão
    const saveBtn = document.getElementById('save-btn');
    const saveText = saveBtn?.querySelector('.save-text');
    const savingText = saveBtn?.querySelector('.saving-text');

    if (saveText && savingText) {
      saveText.classList.remove('hidden');
      savingText.classList.add('hidden');
    }
  }
}

function showNodeProperties(nodeId: string) {
  const container = document.getElementById('node-properties');
  if (!container || !diagram) return;

  const item = diagram.data.getItem(nodeId);
  if (!item) return;

  container.innerHTML = `
    <div class="space-y-3">
      <div>
        <label class="block text-xs font-medium text-gray-700 dark:text-gray-300 mb-1">Nome</label>
        <input type="text" id="node-text" value="${item.text || ''}"
               class="block w-full text-sm rounded-md border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white shadow-sm focus:border-blue-500 focus:ring-blue-500">
      </div>
      <div>
        <label class="block text-xs font-medium text-gray-700 dark:text-gray-300 mb-1">Título/Cargo</label>
        <input type="text" id="node-title" value="${item.title || ''}"
               class="block w-full text-sm rounded-md border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white shadow-sm focus:border-blue-500 focus:ring-blue-500">
      </div>
      <div>
        <label class="block text-xs font-medium text-gray-700 dark:text-gray-300 mb-1">Departamento</label>
        <input type="text" id="node-department" value="${item.data?.department || ''}"
               class="block w-full text-sm rounded-md border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white shadow-sm focus:border-blue-500 focus:ring-blue-500">
      </div>
      <div>
        <label class="block text-xs font-medium text-gray-700 dark:text-gray-300 mb-1">E-mail</label>
        <input type="email" id="node-email" value="${item.data?.email || ''}"
               class="block w-full text-sm rounded-md border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white shadow-sm focus:border-blue-500 focus:ring-blue-500">
      </div>
      <div>
        <label class="block text-xs font-medium text-gray-700 dark:text-gray-300 mb-1">Telefone</label>
        <input type="tel" id="node-phone" value="${item.data?.phone || ''}"
               class="block w-full text-sm rounded-md border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white shadow-sm focus:border-blue-500 focus:ring-blue-500">
      </div>
      <div class="border-t border-gray-200 dark:border-gray-700 pt-3">
        <button id="update-node-btn" class="w-full px-3 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700">
          Atualizar Nó
        </button>
        <button id="add-child-btn" class="w-full mt-2 px-3 py-2 text-sm font-medium text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200 dark:bg-gray-700 dark:text-gray-300 dark:hover:bg-gray-600">
          Adicionar Filho
        </button>
        <button id="remove-node-btn" class="w-full mt-2 px-3 py-2 text-sm font-medium text-white bg-red-600 rounded-md hover:bg-red-700">
          Remover Nó
        </button>
      </div>
    </div>
  `;

  // Event listeners para os campos
  const updateBtn = container.querySelector('#update-node-btn');
  if (updateBtn) {
    updateBtn.addEventListener('click', () => updateNode(nodeId));
  }

  const addChildBtn = container.querySelector('#add-child-btn');
  if (addChildBtn) {
    addChildBtn.addEventListener('click', () => addChildNode(nodeId));
  }

  const removeBtn = container.querySelector('#remove-node-btn');
  if (removeBtn) {
    removeBtn.addEventListener('click', () => removeNode(nodeId));
  }

  // Auto-update ao digitar
  ['node-text', 'node-title', 'node-department', 'node-email', 'node-phone'].forEach(id => {
    const input = container.querySelector(`#${id}`) as HTMLInputElement;
    if (input) {
      input.addEventListener('input', () => updateNode(nodeId));
    }
  });
}

function hideNodeProperties() {
  const container = document.getElementById('node-properties');
  if (container) {
    container.innerHTML = `
      <div class="text-sm text-gray-500 dark:text-gray-400">
        Selecione um nó para editar suas propriedades
      </div>
    `;
  }
}

function updateNode(nodeId: string) {
  if (!diagram) return;

  const container = document.getElementById('node-properties');
  if (!container) return;

  const textInput = container.querySelector('#node-text') as HTMLInputElement;
  const titleInput = container.querySelector('#node-title') as HTMLInputElement;
  const deptInput = container.querySelector('#node-department') as HTMLInputElement;
  const emailInput = container.querySelector('#node-email') as HTMLInputElement;
  const phoneInput = container.querySelector('#node-phone') as HTMLInputElement;

  if (!textInput || !titleInput) return;

  diagram.data.update(nodeId, {
    text: textInput.value,
    title: titleInput.value,
    data: {
      department: deptInput?.value || '',
      email: emailInput?.value || '',
      phone: phoneInput?.value || ''
    }
  });

  markAsUnsaved();
}

function addChildNode(parentId: string) {
  if (!diagram) return;

  const newId = generateId();
  diagram.data.add({
    id: newId,
    text: 'Novo Nó',
    title: 'Cargo',
    parent: parentId,
    type: 'card'
  });

  // Selecionar o novo nó
  setTimeout(() => {
    diagram.selection.add(newId);
  }, 100);
}

function removeNode(nodeId: string) {
  if (!diagram) return;

  if (confirm('Deseja remover este nó? Esta ação não pode ser desfeita.')) {
    diagram.data.remove(nodeId);
    hideNodeProperties();
  }
}

function exportToJson() {
  if (!diagram) return;

  try {
    const nodes: any[] = [];
    diagram.data.eachItem((item: any) => {
      nodes.push({
        id: item.id,
        text: item.text,
        title: item.title,
        parent: item.parent,
        data: item.data || {}
      });
    });

    const nameInput = document.querySelector('#organogram_name') as HTMLInputElement;
    const exportData = {
      name: nameInput?.value || 'Organograma',
      nodes: nodes,
      links: [],
      settings: getCurrentSettings(),
      exported_at: new Date().toISOString()
    };

    const blob = new Blob([JSON.stringify(exportData, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);

    const a = document.createElement('a');
    a.href = url;
    a.download = `organograma-${editorConfig.organogramId}.json`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);

    showToast('JSON exportado com sucesso!', 'success');
  } catch (error) {
    console.error('Erro ao exportar JSON:', error);
    showToast('Erro ao exportar JSON', 'error');
  }
}

async function exportToPdf() {
  if (!diagram) return;

  try {
    showToast('Gerando PDF...', 'info');

    // Ajustar o diagrama para caber na tela
    diagram.zoomToFit();

    // Aguardar um pouco para o diagrama se ajustar
    await new Promise(resolve => setTimeout(resolve, 500));

    const container = document.getElementById('orgchart-editor');
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
    const nameInput = document.querySelector('#organogram_name') as HTMLInputElement;
    pdf.setProperties({
      title: nameInput?.value || 'Organograma',
      subject: 'Organograma organizacional',
      creator: 'Sistema IntegrarPlus',
      keywords: 'organograma, organização, estrutura'
    });

    // Salvar PDF
    pdf.save(`organograma-${editorConfig.organogramId}.pdf`);
    showToast('PDF exportado com sucesso!', 'success');

  } catch (error) {
    console.error('Erro ao exportar PDF:', error);
    showToast('Erro ao exportar PDF', 'error');
  }
}

function getCurrentSettings() {
  if (!diagram) return {};

  return {
    zoom: diagram.zoom || 1,
    theme: 'default',
    layout: 'org'
  };
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

function getCSRFToken(): string {
  const tokenElement = document.querySelector('meta[name="csrf-token"]') as HTMLMetaElement;
  return tokenElement?.content || '';
}

function showToast(message: string, type: 'success' | 'error' | 'info' = 'info') {
  const container = document.getElementById('toast-container');
  if (!container) return;

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
