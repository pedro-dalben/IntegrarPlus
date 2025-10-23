# 📊 Módulo de Fluxogramas - Documentação Completa

## 🎯 Visão Geral

O módulo de Fluxogramas integra o editor draw.io (diagrams.net) ao IntegrarPlus, permitindo criar, editar, visualizar e gerenciar fluxogramas diretamente no sistema, sem necessidade de React ou outras dependências externas.

## 🏗️ Arquitetura

### Stack Tecnológica
- **Backend**: Rails 8.x
- **Frontend**: Hotwire/Stimulus (sem React)
- **Editor**: draw.io embed (iframe + postMessage)
- **Bundler**: Vite
- **Autorização**: Pundit
- **Busca**: MeiliSearch (opcional)
- **i18n**: pt-BR

### Componentes Principais

#### 1. Models
- `FlowChart`: Modelo principal do fluxograma
- `FlowChartVersion`: Versionamento automático

#### 2. Controllers
- `Admin::FlowChartsController`: CRUD completo + ações especiais

#### 3. Views
- `index.html.erb`: Listagem com busca avançada
- `show.html.erb`: Visualização com histórico de versões
- `new.html.erb`: Criação de novo fluxograma
- `edit.html.erb`: Editor integrado com draw.io

#### 4. JavaScript
- `drawio_controller.js`: Stimulus controller para integração via postMessage

#### 5. Policies
- `FlowChartPolicy`: Controle de permissões

## 📋 Estrutura do Banco de Dados

### Tabela: flow_charts
```ruby
- id: bigint (PK)
- title: string (obrigatório)
- description: text
- status: integer (enum: draft=0, published=1, archived=2)
- current_version_id: bigint (FK -> flow_chart_versions)
- created_by_id: bigint (FK -> professionals)
- updated_by_id: bigint (FK -> professionals)
- created_at: datetime
- updated_at: datetime
```

### Tabela: flow_chart_versions
```ruby
- id: bigint (PK)
- flow_chart_id: bigint (FK -> flow_charts)
- data_format: integer (enum: xml=0, svg=1)
- data: longtext (até 16MB)
- version: integer (auto-incrementado)
- notes: text
- created_by_id: bigint (FK -> professionals)
- created_at: datetime
- updated_at: datetime
```

### Índices
- `flow_charts`: status, created_by_id, updated_by_id, current_version_id
- `flow_chart_versions`: version, created_by_id, [flow_chart_id, version] (unique)

## 🔐 Sistema de Permissões

### Permissões Disponíveis

1. **flow_charts.index** - Listar fluxogramas
   - Disponível para: Todos os usuários autenticados

2. **flow_charts.show** - Ver detalhes de fluxograma
   - Disponível para: Todos os usuários autenticados

3. **flow_charts.manage** - Gerenciar fluxogramas
   - Disponível para: Administradores e usuários com permissão específica
   - Inclui: criar, editar, excluir, publicar, duplicar

### Configuração de Permissões

No seed de grupos, adicione a permissão aos grupos desejados:

```ruby
gestao_processos = Group.find_by(name: 'Gestão de Processos')
flow_charts_manage = Permission.find_by(key: 'flow_charts.manage')
gestao_processos.permissions << flow_charts_manage
```

### Regras da Policy

```ruby
# Visualização
def index?
  true  # Todos podem ver a lista
end

def show?
  true  # Todos podem ver detalhes
end

# Gerenciamento
def create?
  user.admin? || user.permit?('flow_charts.manage')
end

def update?
  user.admin? || user.permit?('flow_charts.manage')
end

def destroy?
  user.admin? || user.permit?('flow_charts.manage')
end

def publish?
  user.admin? || user.permit?('flow_charts.manage')
end

def duplicate?
  user.admin? || user.permit?('flow_charts.manage')
end
```

## 🎨 Interface do Usuário

### Página de Listagem (Index)

**Funcionalidades:**
- Busca avançada com MeiliSearch
- Grid responsivo com cards
- Badges de status (Rascunho, Publicado, Arquivado)
- Indicador de versão atual
- Ações rápidas (ver, editar, excluir)
- Paginação

**Colunas:**
- Título e descrição
- Status
- Versão
- Criado por
- Última atualização
- Ações

### Página de Visualização (Show)

**Seções:**
1. **Cabeçalho**
   - Título
   - Status badge
   - Número da versão
   - Botões de ação (Editar, Duplicar, Publicar)

2. **Informações**
   - Descrição
   - Criado por
   - Datas de criação e atualização

3. **Preview do Fluxograma**
   - Iframe do draw.io em modo somente leitura
   - Carregamento automático da versão atual

4. **Histórico de Versões**
   - Lista de todas as versões
   - Indicador da versão atual
   - Autor e data de cada versão
   - Notas da versão (se houver)

### Página de Edição (Edit)

**Layout:**
1. **Toolbar Superior**
   - Salvar Versão
   - Exportar PNG
   - Exportar SVG
   - Indicador de status de salvamento

2. **Editor Draw.io**
   - Iframe integrado
   - Modo completo de edição
   - Bibliotecas habilitadas (BPMN, UML, ER, etc.)

3. **Campo de Notas**
   - Texto livre para documentar alterações

4. **Formulário de Informações**
   - Título
   - Descrição
   - Status

**Instruções de Uso:**
- Editar normalmente no draw.io
- Clicar em "Salvar Versão" cria nova versão
- Exportar permite download local

## 🔄 Sistema de Versionamento

### Como Funciona

1. **Criação Inicial**
   - Fluxograma criado como rascunho
   - Primeira edição cria versão 1
   - `current_version_id` aponta para v1

2. **Salvamento**
   - Cada "Salvar" cria nova versão
   - Versão auto-incrementada (2, 3, 4...)
   - `current_version_id` atualizado automaticamente
   - Notas opcionais para documentar mudanças

3. **Publicação**
   - Requer pelo menos uma versão
   - Muda status de `draft` para `published`
   - Mantém versão atual

4. **Histórico**
   - Todas as versões são mantidas
   - Possível ver quem criou e quando
   - Notas explicativas preservadas

### Exemplo de Fluxo

```ruby
# Criar fluxograma
flow_chart = FlowChart.create!(
  title: 'Processo X',
  status: :draft,
  created_by: current_professional
)

# Primeira edição (versão 1)
flow_chart.versions.create!(
  data: xml_data,
  notes: 'Versão inicial',
  created_by: current_professional
)

# Segunda edição (versão 2)
flow_chart.versions.create!(
  data: xml_data_v2,
  notes: 'Adicionei etapa de aprovação',
  created_by: current_professional
)

# Publicar
flow_chart.publish! if flow_chart.can_publish?
```

## 🔌 Integração Draw.io

### Protocolo postMessage

O Stimulus controller se comunica com o iframe via mensagens:

#### Mensagens Enviadas (App → Draw.io)

**1. Carregar Diagrama**
```javascript
{
  action: 'load',
  xml: '<mxfile>...</mxfile>',
  autosave: 1
}
```

**2. Exportar**
```javascript
{
  action: 'export',
  format: 'png' | 'svg' | 'xml',
  embedImages: true
}
```

**3. Configurar**
```javascript
{
  action: 'configure',
  config: {
    defaultLibraries: "general;uml;er;bpmn",
    autosave: 1,
    saveAndExit: false
  }
}
```

#### Mensagens Recebidas (Draw.io → App)

**1. Inicialização**
```javascript
{
  event: 'init'
}
```

**2. Salvamento**
```javascript
{
  event: 'save',
  xml: '<mxfile>...</mxfile>'
}
```

**3. Exportação**
```javascript
{
  event: 'export',
  data: 'data:image/png;base64,...',
  format: 'png'
}
```

### Stimulus Controller

**Targets:**
- `iframe`: O iframe do draw.io
- `saveIndicator`: Spinner de loading
- `saveStatus`: Mensagem de status
- `versionNotes`: Campo de notas

**Values:**
- `flowChartId`: ID do fluxograma
- `updateUrl`: URL para salvar
- `exportUrl`: URL para exportar
- `initialData`: XML inicial

**Actions:**
- `save()`: Salva nova versão
- `exportPNG()`: Exporta para PNG
- `exportSVG()`: Exporta para SVG

### URL do Embed

```
https://embed.diagrams.net/?embed=1&ui=atlas&spin=1&proto=json&configure=1&libraries=1
```

**Parâmetros:**
- `embed=1`: Modo embarcado
- `ui=atlas`: Interface Atlas (mais moderna)
- `spin=1`: Mostrar spinner de loading
- `proto=json`: Protocolo JSON para postMessage
- `configure=1`: Permitir configuração
- `libraries=1`: Habilitar todas as bibliotecas

## 📝 Rotas

```ruby
namespace :admin do
  resources :flow_charts do
    member do
      post :publish     # Publicar fluxograma
      post :duplicate   # Duplicar fluxograma
      post :export_pdf  # Exportar para PDF (futuro)
    end
  end
end
```

**URLs Geradas:**
- `GET    /admin/flow_charts` → index
- `GET    /admin/flow_charts/new` → new
- `POST   /admin/flow_charts` → create
- `GET    /admin/flow_charts/:id` → show
- `GET    /admin/flow_charts/:id/edit` → edit
- `PATCH  /admin/flow_charts/:id` → update
- `DELETE /admin/flow_charts/:id` → destroy
- `POST   /admin/flow_charts/:id/publish` → publish
- `POST   /admin/flow_charts/:id/duplicate` → duplicate
- `POST   /admin/flow_charts/:id/export_pdf` → export_pdf

## 🧪 Seeds

### Executar Seeds

```bash
# Rodar todos os seeds (inclui fluxogramas)
bin/rails db:seed

# Rodar apenas fluxogramas
bin/rails runner "load Rails.root.join('db/seeds/flow_charts_setup.rb')"
```

### Dados de Exemplo

O seed cria:
1. **Fluxograma Publicado**: "Processo de Atendimento Padrão"
   - Status: published
   - Com diagrama completo de exemplo
   - Versão inicial

2. **Fluxograma Rascunho**: "Fluxograma em Desenvolvimento"
   - Status: draft
   - Sem versões (pronto para primeira edição)

## 🚀 Como Usar

### 1. Para Usuários Finais

**Visualizar Fluxogramas:**
1. Acesse "Fluxogramas" no menu admin
2. Veja a lista de todos os fluxogramas
3. Clique em um fluxograma para ver detalhes
4. Visualize o diagrama e histórico de versões

**Criar Novo Fluxograma:**
1. Clique em "Novo Fluxograma"
2. Preencha título e descrição
3. Clique em "Criar e Editar Diagrama"
4. Aguarde carregar o editor
5. Crie seu diagrama no draw.io
6. Adicione notas (opcional)
7. Clique em "Salvar Versão"

**Editar Fluxograma:**
1. Na lista, clique em "Editar"
2. Modifique o diagrama
3. Adicione notas sobre as mudanças
4. Clique em "Salvar Versão"
5. Nova versão é criada automaticamente

**Publicar:**
1. Certifique-se de ter pelo menos uma versão
2. Clique em "Publicar"
3. Status muda para "Publicado"

**Duplicar:**
1. Clique em "Duplicar"
2. Cópia criada como rascunho
3. Título recebe "(cópia)"
4. Mantém conteúdo da última versão

**Exportar:**
1. Vá para edição
2. Clique em "Exportar PNG" ou "Exportar SVG"
3. Arquivo baixado automaticamente

### 2. Para Desenvolvedores

**Adicionar ao Menu:**

```ruby
# app/navigation/admin_nav.rb (se existir)
{
  name: 'Fluxogramas',
  path: admin_flow_charts_path,
  icon: 'flowchart',
  required_permission: 'flow_charts.index'
}
```

**Criar Fluxograma Programaticamente:**

```ruby
professional = Professional.find_by(email: 'usuario@exemplo.com')

flow_chart = FlowChart.create!(
  title: 'Novo Processo',
  description: 'Descrição do processo',
  status: :draft,
  created_by: professional,
  updated_by: professional
)

# Criar primeira versão
version = flow_chart.versions.create!(
  data: xml_data,
  data_format: :xml,
  notes: 'Versão inicial',
  created_by: professional
)

# Definir como versão atual
flow_chart.update!(current_version: version)
```

**Verificar Permissões:**

```ruby
# No controller
authorize FlowChart  # Para index/new
authorize @flow_chart  # Para show/edit/etc

# Na view
<% if policy(FlowChart).create? %>
  <%= link_to 'Novo', new_admin_flow_chart_path %>
<% end %>

<% if policy(@flow_chart).update? %>
  <%= link_to 'Editar', edit_admin_flow_chart_path(@flow_chart) %>
<% end %>
```

## 🔧 Manutenção

### Logs

O Stimulus controller registra eventos importantes:
- Carregamento do iframe
- Inicialização do draw.io
- Salvamentos
- Exportações
- Erros

Verifique no console do navegador (F12).

### Troubleshooting

**Problema: Iframe não carrega**
- Verifique Content Security Policy (CSP)
- Certifique-se de permitir `https://embed.diagrams.net`
- Verifique firewall/proxy

**Problema: Salvamento não funciona**
- Verifique CSRF token
- Confirme que há dados no diagrama
- Verifique logs do servidor

**Problema: Exportação falha**
- Aguarde alguns segundos após edição
- Tente recarregar a página
- Verifique se há bloqueador de pop-ups

**Problema: Permissões negadas**
- Verifique se usuário tem permissão `flow_charts.manage`
- Confirme que seed de permissões foi executado
- Verifique grupos do usuário

### Backup

```bash
# Backup das tabelas
pg_dump -t flow_charts -t flow_chart_versions nome_do_banco > flow_charts_backup.sql

# Restaurar
psql nome_do_banco < flow_charts_backup.sql
```

## 📚 Referências

- [Draw.io Embed Mode](https://www.drawio.com/doc/faq/embed-mode)
- [Draw.io JavaScript API](https://www.drawio.com/doc/faq/embed-mode)
- [Stimulus Handbook](https://stimulus.hotwired.dev/)
- [Pundit Documentation](https://github.com/varvet/pundit)

## 🎓 Boas Práticas

1. **Sempre adicione notas às versões** - facilita rastreamento de mudanças
2. **Publique apenas fluxogramas finalizados** - rascunho para trabalho em progresso
3. **Use títulos descritivos** - ajuda na busca e organização
4. **Revise o histórico antes de editar** - entenda evolução do fluxograma
5. **Faça backup antes de grandes mudanças** - segurança adicional
6. **Teste em ambiente de desenvolvimento** - antes de produção

## 📊 Estatísticas

Para obter estatísticas do sistema:

```ruby
# Total de fluxogramas
FlowChart.count

# Por status
FlowChart.draft.count
FlowChart.published.count
FlowChart.archived.count

# Total de versões
FlowChartVersion.count

# Média de versões por fluxograma
FlowChart.joins(:versions).group('flow_charts.id').average('COUNT(flow_chart_versions.id)')

# Fluxogramas mais editados
FlowChart.joins(:versions)
  .select('flow_charts.*, COUNT(flow_chart_versions.id) as version_count')
  .group('flow_charts.id')
  .order('version_count DESC')
  .limit(10)
```

---

**Versão**: 1.0.0
**Data**: Outubro 2024
**Autor**: IntegrarPlus Team
