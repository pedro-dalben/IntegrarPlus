import Papa from 'papaparse';

interface CSVRow {
  id?: string;
  pid?: string;
  name: string;
  role_title?: string;
  department?: string;
  email?: string;
  phone?: string;
  [key: string]: any;
}

interface OrganogramNode {
  id: string;
  text: string;
  title?: string;
  parent?: string;
  data?: {
    department?: string;
    email?: string;
    phone?: string;
    [key: string]: any;
  };
}

interface ProcessResult {
  success: boolean;
  nodes: OrganogramNode[];
  errors: string[];
  warnings: string[];
}

export function validateCSVHeaders(headers: string[]): { valid: boolean; errors: string[] } {
  const requiredHeaders = ['name'];
  const optionalHeaders = ['id', 'pid', 'role_title', 'department', 'email', 'phone'];
  const validHeaders = [...requiredHeaders, ...optionalHeaders];

  const errors: string[] = [];

  // Verificar se headers obrigatórios estão presentes
  for (const header of requiredHeaders) {
    if (!headers.includes(header)) {
      errors.push(`Campo obrigatório '${header}' não encontrado`);
    }
  }

  // Verificar se há headers inválidos
  for (const header of headers) {
    if (!validHeaders.includes(header)) {
      errors.push(`Campo '${header}' não é reconhecido`);
    }
  }

  return {
    valid: errors.length === 0,
    errors
  };
}

export function processCSVData(csvText: string): ProcessResult {
  const result: ProcessResult = {
    success: false,
    nodes: [],
    errors: [],
    warnings: []
  };

  try {
    // Parse do CSV
    const parseResult = Papa.parse<CSVRow>(csvText, {
      header: true,
      skipEmptyLines: true,
      transformHeader: (header: string) => header.trim().toLowerCase(),
      transform: (value: string) => value.trim()
    });

    if (parseResult.errors.length > 0) {
      result.errors = parseResult.errors.map(error => `Linha ${error.row + 1}: ${error.message}`);
      return result;
    }

    const data = parseResult.data;
    if (data.length === 0) {
      result.errors.push('Arquivo CSV vazio ou sem dados válidos');
      return result;
    }

    // Validar headers
    const headers = Object.keys(data[0]);
    const headerValidation = validateCSVHeaders(headers);
    if (!headerValidation.valid) {
      result.errors.push(...headerValidation.errors);
      return result;
    }

    // Processar dados
    const processedData = processRowsToNodes(data);
    result.nodes = processedData.nodes;
    result.errors.push(...processedData.errors);
    result.warnings.push(...processedData.warnings);

    // Validar estrutura hierárquica
    const hierarchyValidation = validateHierarchy(result.nodes);
    result.errors.push(...hierarchyValidation.errors);
    result.warnings.push(...hierarchyValidation.warnings);

    result.success = result.errors.length === 0;
    return result;

  } catch (error) {
    result.errors.push(`Erro ao processar CSV: ${error instanceof Error ? error.message : 'Erro desconhecido'}`);
    return result;
  }
}

function processRowsToNodes(rows: CSVRow[]): { nodes: OrganogramNode[]; errors: string[]; warnings: string[] } {
  const nodes: OrganogramNode[] = [];
  const errors: string[] = [];
  const warnings: string[] = [];
  const usedIds = new Set<string>();

  for (let i = 0; i < rows.length; i++) {
    const row = rows[i];
    const rowNumber = i + 2; // +2 porque começamos do 1 e temos header

    // Validar nome obrigatório
    if (!row.name || row.name.trim() === '') {
      errors.push(`Linha ${rowNumber}: Nome é obrigatório`);
      continue;
    }

    // Gerar ID se não fornecido
    let nodeId = row.id || generateId();

    // Garantir ID único
    if (usedIds.has(nodeId)) {
      const originalId = nodeId;
      nodeId = generateId();
      warnings.push(`Linha ${rowNumber}: ID '${originalId}' duplicado, gerado novo ID '${nodeId}'`);
    }
    usedIds.add(nodeId);

    // Validar email se fornecido
    if (row.email && !isValidEmail(row.email)) {
      warnings.push(`Linha ${rowNumber}: Email '${row.email}' não é válido`);
    }

    // Validar telefone se fornecido
    if (row.phone && !isValidPhone(row.phone)) {
      warnings.push(`Linha ${rowNumber}: Telefone '${row.phone}' não é válido`);
    }

    // Criar nó
    const node: OrganogramNode = {
      id: nodeId,
      text: row.name.trim(),
      title: row.role_title?.trim() || '',
      parent: row.pid?.trim() || undefined
    };

    // Adicionar dados extras
    const data: any = {};
    if (row.department?.trim()) data.department = row.department.trim();
    if (row.email?.trim()) data.email = row.email.trim();
    if (row.phone?.trim()) data.phone = normalizePhone(row.phone.trim());

    if (Object.keys(data).length > 0) {
      node.data = data;
    }

    nodes.push(node);
  }

  return { nodes, errors, warnings };
}

function validateHierarchy(nodes: OrganogramNode[]): { errors: string[]; warnings: string[] } {
  const errors: string[] = [];
  const warnings: string[] = [];

  if (nodes.length === 0) {
    errors.push('Nenhum nó válido encontrado');
    return { errors, warnings };
  }

  const nodeIds = new Set(nodes.map(node => node.id));
  const rootNodes = nodes.filter(node => !node.parent);
  const orphanNodes: OrganogramNode[] = [];

  // Verificar nós órfãos (referenciam pais que não existem)
  for (const node of nodes) {
    if (node.parent && !nodeIds.has(node.parent)) {
      orphanNodes.push(node);
    }
  }

  // Verificar se há pelo menos um nó raiz
  if (rootNodes.length === 0) {
    if (orphanNodes.length > 0) {
      // Converter o primeiro órfão em raiz
      orphanNodes[0].parent = undefined;
      warnings.push(`Nenhuma raiz encontrada, convertendo '${orphanNodes[0].text}' em nó raiz`);
    } else {
      errors.push('Nenhum nó raiz encontrado');
    }
  } else if (rootNodes.length > 1) {
    warnings.push(`Múltiplas raízes encontradas (${rootNodes.length}), considere ter apenas uma raiz`);
  }

  // Avisar sobre nós órfãos
  if (orphanNodes.length > 0) {
    warnings.push(`${orphanNodes.length} nó(s) órfão(s) encontrado(s): ${orphanNodes.map(n => n.text).join(', ')}`);
  }

  // Verificar ciclos
  const cycleResult = detectCycles(nodes);
  if (cycleResult.hasCycles) {
    errors.push(`Ciclos detectados na hierarquia: ${cycleResult.cycles.join(', ')}`);
  }

  return { errors, warnings };
}

function detectCycles(nodes: OrganogramNode[]): { hasCycles: boolean; cycles: string[] } {
  const nodeMap = new Map<string, OrganogramNode>();
  const cycles: string[] = [];

  // Criar mapa para acesso rápido
  for (const node of nodes) {
    nodeMap.set(node.id, node);
  }

  const visited = new Set<string>();
  const visiting = new Set<string>();

  function dfs(nodeId: string, path: string[]): boolean {
    if (visiting.has(nodeId)) {
      // Ciclo detectado
      const cycleStart = path.indexOf(nodeId);
      const cycle = path.slice(cycleStart).concat(nodeId);
      cycles.push(cycle.join(' → '));
      return true;
    }

    if (visited.has(nodeId)) {
      return false;
    }

    visiting.add(nodeId);
    const node = nodeMap.get(nodeId);

    if (node?.parent) {
      const newPath = [...path, nodeId];
      if (dfs(node.parent, newPath)) {
        return true;
      }
    }

    visiting.delete(nodeId);
    visited.add(nodeId);
    return false;
  }

  // Verificar cada nó
  for (const node of nodes) {
    if (!visited.has(node.id)) {
      dfs(node.id, []);
    }
  }

  return {
    hasCycles: cycles.length > 0,
    cycles
  };
}

function generateId(): string {
  return 'node_' + Math.random().toString(36).substr(2, 9) + Date.now().toString(36);
}

function isValidEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

function isValidPhone(phone: string): boolean {
  // Aceitar formatos: (11) 99999-9999, 11999999999, +55 11 99999-9999, etc.
  const phoneRegex = /^[\+]?[\d\s\(\)\-]{8,}$/;
  return phoneRegex.test(phone);
}

function normalizePhone(phone: string): string {
  // Manter apenas números
  return phone.replace(/\D/g, '');
}

export function generateCSVTemplate(): string {
  const headers = ['id', 'pid', 'name', 'role_title', 'department', 'email', 'phone'];
  const sampleData = [
    ['ceo', '', 'João Silva', 'CEO', 'Diretoria', 'joao@empresa.com', '(11) 99999-0001'],
    ['cto', 'ceo', 'Maria Santos', 'CTO', 'Tecnologia', 'maria@empresa.com', '(11) 99999-0002'],
    ['cfo', 'ceo', 'Pedro Oliveira', 'CFO', 'Financeiro', 'pedro@empresa.com', '(11) 99999-0003'],
    ['dev1', 'cto', 'Ana Costa', 'Desenvolvedora', 'Tecnologia', 'ana@empresa.com', '(11) 99999-0004'],
    ['dev2', 'cto', 'Carlos Lima', 'Desenvolvedor', 'Tecnologia', 'carlos@empresa.com', '(11) 99999-0005']
  ];

  const csvContent = [headers, ...sampleData]
    .map(row => row.map(cell => `"${cell}"`).join(','))
    .join('\n');

  return csvContent;
}

export function downloadCSVTemplate(): void {
  const csvContent = generateCSVTemplate();
  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
  const url = URL.createObjectURL(blob);

  const a = document.createElement('a');
  a.href = url;
  a.download = 'organograma-template.csv';
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);
}
