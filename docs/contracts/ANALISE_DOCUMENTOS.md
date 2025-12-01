# Análise dos Documentos de Contrato

## Estrutura dos Documentos

### 1. Atribuição de Cargos (`atribuiçao_De_Cargos.md`)

**Características identificadas**:
- Documento extenso (ex: linha 918 menciona medidas disciplinares)
- Estrutura markdown com múltiplas seções
- Descrições detalhadas por cargo/função
- Formatação com:
  - Títulos hierárquicos (`#`, `##`, `###`)
  - Parágrafos de texto
  - Listas com bullets (`-`)
  - Texto sobre responsabilização legal

**Uso no sistema**:
- Conteúdo será armazenado em `JobRole.description`
- Será usado para gerar o Anexo I do contrato
- Precisa ser convertido de markdown para PDF usando Prawn

### 2. Contrato de Prestação de Serviços

**Estrutura esperada**:
- Cláusulas numeradas (ex: Cláusula 17ª)
- Dados variáveis do profissional (nome, CPF, RG, endereços)
- Cláusula 17 parametrizada conforme tipo de pagamento
- Bloco de assinaturas

### 3. Termo de Uso de Imagem

**Estrutura esperada**:
- Documento mais simples
- Dados básicos do profissional
- Texto padrão sobre uso de imagem

## Estratégia de Conversão Markdown → PDF

### Processo

1. **Parse do Markdown**
   - Usar gem `kramdown` ou `redcarpet`
   - Identificar elementos: títulos, parágrafos, listas, formatação

2. **Mapeamento para Prawn**
   - `# Título` → `pdf.text "Título", size: 16, style: :bold`
   - `## Subtítulo` → `pdf.text "Subtítulo", size: 14, style: :bold`
   - `- Item` → Lista com bullets usando `pdf.indent(20)`
   - Parágrafos → `pdf.text` com espaçamento adequado
   - Negrito `**texto**` → `pdf.text "texto", style: :bold`
   - Itálico `*texto*` → `pdf.text "texto", style: :italic`

3. **Preservar Hierarquia**
   - Manter indentação e espaçamento
   - Respeitar quebras de página quando necessário

## Serviços Necessários

### MarkdownToPrawnConverter
- Converte texto markdown em comandos Prawn
- Métodos: `convert`, `render_heading`, `render_paragraph`, `render_list`

### ContractPdfService
- Gera PDFs dos documentos
- Usa MarkdownToPrawnConverter quando necessário
- Aplica formatação consistente

