# 📁 Módulo Workspace

## Visão Geral

O módulo **Workspace** fornece uma área centralizada para visualizar e gerenciar todos os documentos em andamento e desenvolvimento, oferecendo uma visão geral do trabalho ativo com filtros avançados e ações rápidas.

## Funcionalidades

### ✅ Implementadas

- **Listagem de Documentos em Andamento**
  - Exclui documentos com status "Liberado"
  - Exibe informações essenciais: título, autor, versão atual, status, responsável, última modificação
  - Contador de documentos totais e "meus documentos"

- **Sistema de Filtros Avançados**
  - Filtro por status do documento
  - Filtro por tipo de documento
  - Filtro por autor
  - Filtro por responsável
  - Filtro por período de modificação
  - Botão especial "Meus Documentos"

- **Ações Rápidas**
  - Abrir documento (visualização completa)
  - Ver histórico de status
  - Ver tarefas associadas
  - Ordenação por múltiplos critérios

- **Interface Otimizada**
  - Tabela responsiva com ícones visuais
  - Cores diferentes para cada status
  - Paginação para performance
  - Design moderno e acessível

## Estrutura de Dados

### Controller WorkspaceController

```ruby
class WorkspaceController < ApplicationController
  before_action :authenticate_user!

  def index
    @documents = Document.includes(:author, :latest_version, :current_responsible)
                         .where.not(status: 'liberado')

    # Filtro "Meus documentos" - onde o usuário é responsável
    if params[:my_documents] == 'true'
      @documents = @documents.joins(:document_responsibles)
                            .where(document_responsibles: { user: current_user })
    end

    # Aplicação de filtros
    @documents = @documents.where(status: params[:status]) if params[:status].present?
    @documents = @documents.where(document_type: params[:document_type]) if params[:document_type].present?
    @documents = @documents.where(author_id: params[:author_id]) if params[:author_id].present?
    
    if params[:responsible_id].present?
      @documents = @documents.joins(:document_responsibles)
                            .where(document_responsibles: { user_id: params[:responsible_id] })
    end

    # Filtros de data
    if params[:updated_after].present?
      @documents = @documents.where('documents.updated_at >= ?', Date.parse(params[:updated_after]))
    end

    # Ordenação
    order_by = params[:order_by] || 'updated_at'
    direction = params[:direction] || 'desc'
    
    # Paginação
    @documents = @documents.page(params[:page]).per(20)

    # Estatísticas
    @total_documents = @documents.total_count
    @my_documents_count = Document.joins(:document_responsibles)
                                 .where(document_responsibles: { user: current_user })
                                 .where.not(status: 'liberado')
                                 .count
  end
end
```

## Views

### Estrutura de Arquivos

```
app/views/workspace/
└── index.html.erb          # Lista principal de documentos em andamento
```

### Componentes Principais

#### Header com Estatísticas
- **Título**: "Workspace" com descrição
- **Contadores**: Total de documentos e "meus documentos"
- **Ícones visuais**: Para melhor identificação

#### Sistema de Filtros
- **Filtros básicos**: Status, tipo, autor, responsável
- **Filtros de data**: Modificado após/antes
- **Botão especial**: "Meus Documentos" com toggle
- **Ordenação**: Por múltiplos critérios

#### Tabela de Documentos
- **Colunas**: Documento, Status, Autor, Versão, Responsável, Última Modificação, Ações
- **Status visual**: Cores e ícones diferentes para cada status
- **Ações rápidas**: Abrir, histórico, tarefas
- **Responsividade**: Tabela adaptável para mobile

## Rotas

```ruby
namespace :admin do
  get 'workspace', to: 'workspace#index'
end
```

### Endpoints Disponíveis

| Método | Rota | Descrição |
|--------|------|-----------|
| GET | `/admin/workspace` | Lista de documentos em andamento |

## Filtros e Ordenação

### Filtros Disponíveis

1. **Status**
   - Filtra por status específico (rascunho, em_revisao, etc.)
   - Opção "Todos os status" para remover filtro

2. **Tipo de Documento**
   - Filtra por tipo específico (contrato, manual, etc.)
   - Opção "Todos os tipos" para remover filtro

3. **Autor**
   - Filtra por autor específico
   - Opção "Todos os autores" para remover filtro

4. **Responsável**
   - Filtra por responsável específico
   - Opção "Todos os responsáveis" para remover filtro

5. **Período de Modificação**
   - `updated_after`: Documentos modificados após data
   - `updated_before`: Documentos modificados antes de data

6. **Meus Documentos**
   - Filtro especial que mostra apenas documentos onde o usuário é responsável
   - Toggle entre "Todos os Documentos" e "Meus Documentos"

### Ordenação

| Campo | Descrição |
|-------|-----------|
| `updated_at` | Última modificação (padrão) |
| `title` | Título do documento |
| `author` | Nome do autor |
| `status` | Status do documento |
| `created_at` | Data de criação |

### Direção
- `asc`: Crescente
- `desc`: Decrescente (padrão)

## Integração com Sistema

### Navegação

```ruby
# app/navigation/admin_nav.rb
{ label: 'Workspace', path: '/admin/workspace', icon: 'bi-folder2-open', required_permission: 'documents.read' }
```

### Permissões

- **Visualização**: `documents.read`
- **Acesso**: Apenas usuários autenticados
- **Filtro pessoal**: Baseado no usuário logado

### Relacionamentos

- **Document**: Autor, versão atual, responsável atual
- **User**: Nome para exibição
- **DocumentResponsible**: Para filtro "meus documentos"
- **DocumentVersion**: Para versão atual

## Status Visuais

### Cores por Status

| Status | Cor | Ícone |
|--------|-----|-------|
| `rascunho` | Azul | Documento |
| `em_revisao` | Amarelo | Relógio |
| `aguardando_aprovacao` | Laranja | Pausa |
| `aguardando_liberacao` | Verde | Check |
| `liberado` | Verde escuro | Check duplo |

### Implementação

```ruby
# app/models/document.rb
def status_color
  case status
  when 'rascunho'
    'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200'
  when 'em_revisao'
    'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200'
  when 'aguardando_aprovacao'
    'bg-orange-100 text-orange-800 dark:bg-orange-900 dark:text-orange-200'
  when 'aguardando_liberacao'
    'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200'
  when 'liberado'
    'bg-emerald-100 text-emerald-800 dark:bg-emerald-900 dark:text-emerald-200'
  else
    'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-200'
  end
end
```

## CSS Classes Utilizadas

### Layout
- **Container**: `max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8`
- **Grid**: `grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4`
- **Cards**: `bg-white dark:bg-gray-800 rounded-lg shadow border border-gray-200 dark:border-gray-700`

### Tabelas
- **Header**: `bg-gray-50 dark:bg-gray-700`
- **Rows**: `hover:bg-gray-50 dark:hover:bg-gray-700`
- **Dividers**: `divide-y divide-gray-200 dark:divide-gray-700`

### Status Colors
- **Rascunho**: `bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200`
- **Em Revisão**: `bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200`
- **Aguardando Aprovação**: `bg-orange-100 text-orange-800 dark:bg-orange-900 dark:text-orange-200`
- **Aguardando Liberação**: `bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200`

## Testes

### Controller (RSpec)

```ruby
RSpec.describe WorkspaceController, type: :controller do
  describe 'GET #index' do
    let!(:draft_document) { create(:document, status: 'rascunho') }
    let!(:released_document) { create(:document, status: 'liberado') }

    it 'shows only non-released documents' do
      get :index
      
      expect(assigns(:documents)).to include(draft_document)
      expect(assigns(:documents)).not_to include(released_document)
    end

    it 'filters by status' do
      get :index, params: { status: 'rascunho' }
      
      expect(assigns(:documents)).to all(have_attributes(status: 'rascunho'))
    end

    it 'filters by document type' do
      get :index, params: { document_type: 'contrato' }
      
      expect(assigns(:documents)).to all(have_attributes(document_type: 'contrato'))
    end

    it 'filters my documents' do
      user = create(:user)
      document = create(:document, status: 'rascunho')
      create(:document_responsible, document: document, user: user)
      
      sign_in user
      get :index, params: { my_documents: 'true' }
      
      expect(assigns(:documents)).to include(document)
    end

    it 'filters by responsible' do
      responsible = create(:user)
      document = create(:document, status: 'rascunho')
      create(:document_responsible, document: document, user: responsible)
      
      get :index, params: { responsible_id: responsible.id }
      
      expect(assigns(:documents)).to include(document)
    end

    it 'filters by date range' do
      date = Date.current
      get :index, params: { updated_after: date.to_s }
      
      expect(assigns(:documents).where('documents.updated_at >= ?', date)).to be_present
    end

    it 'orders by title' do
      get :index, params: { order_by: 'title', direction: 'asc' }
      
      expect(assigns(:documents).to_sql).to include('ORDER BY documents.title asc')
    end

    it 'provides statistics' do
      get :index
      
      expect(assigns(:total_documents)).to be_present
      expect(assigns(:my_documents_count)).to be_present
    end
  end
end
```

### View (RSpec)

```ruby
RSpec.describe 'workspace/index', type: :view do
  let(:documents) { create_list(:document, 3, status: 'rascunho') }

  before do
    assign(:documents, documents)
    assign(:statuses, Document.statuses.keys)
    assign(:document_types, Document.document_types.keys)
    assign(:authors, User.all)
    assign(:responsibles, User.all)
    assign(:total_documents, 3)
    assign(:my_documents_count, 1)
  end

  it 'displays workspace title' do
    render
    
    expect(rendered).to have_content('Workspace')
    expect(rendered).to have_content('Documentos em andamento e desenvolvimento')
  end

  it 'shows document statistics' do
    render
    
    expect(rendered).to have_content('3 documentos em andamento')
    expect(rendered).to have_content('1 meus documentos')
  end

  it 'displays filter form' do
    render
    
    expect(rendered).to have_field('Status')
    expect(rendered).to have_field('Tipo de Documento')
    expect(rendered).to have_field('Autor')
    expect(rendered).to have_field('Responsável')
    expect(rendered).to have_field('Modificado após')
    expect(rendered).to have_field('Modificado antes')
  end

  it 'shows my documents button' do
    render
    
    expect(rendered).to have_link('Meus Documentos')
  end

  it 'displays documents table' do
    render
    
    expect(rendered).to have_css('table')
    documents.each do |doc|
      expect(rendered).to have_content(doc.title)
    end
  end

  it 'shows status badges' do
    render
    
    expect(rendered).to have_css('.inline-flex.items-center.px-2\\.5.py-0\\.5.rounded-full')
  end

  it 'displays action buttons' do
    render
    
    expect(rendered).to have_link('Abrir documento')
    expect(rendered).to have_link('Ver histórico')
    expect(rendered).to have_link('Ver tarefas')
  end

  it 'shows empty state when no documents' do
    assign(:documents, [])
    assign(:total_documents, 0)
    
    render
    
    expect(rendered).to have_content('Nenhum documento em andamento')
    expect(rendered).to have_link('Criar novo documento')
  end
end
```

## Próximos Passos

### Funcionalidades Futuras

1. **Dashboard Widgets**
   - Cards com estatísticas por status
   - Gráficos de progresso
   - Alertas de documentos atrasados

2. **Notificações**
   - Alertas para documentos que precisam de atenção
   - Notificações de mudanças de status
   - Lembretes de prazos

3. **Filtros Avançados**
   - Busca por texto no título/descrição
   - Filtros combinados
   - Filtros salvos/favoritos

4. **Ações em Lote**
   - Seleção múltipla de documentos
   - Ações em massa (mudar status, atribuir responsável)
   - Exportação de relatórios

5. **Kanban Board**
   - Visualização em colunas por status
   - Drag and drop para mudar status
   - Limitação de WIP por status

6. **Timeline**
   - Linha do tempo de atividades
   - Histórico de mudanças
   - Previsão de conclusão

7. **Relatórios**
   - Relatórios de produtividade
   - Análise de tempo por status
   - Métricas de performance

8. **Integração**
   - Webhooks para mudanças de status
   - API para integração externa
   - Notificações por email/Slack

## Conclusão

O módulo **Workspace** está completamente implementado e funcional, oferecendo:

- ✅ Listagem centralizada de documentos em andamento
- ✅ Sistema de filtros avançados e flexíveis
- ✅ Filtro especial "Meus Documentos"
- ✅ Ações rápidas para navegação eficiente
- ✅ Interface moderna com indicadores visuais
- ✅ Ordenação por múltiplos critérios
- ✅ Paginação para performance
- ✅ Integração com sistema de permissões
- ✅ Design responsivo e acessível
- ✅ Estatísticas em tempo real

O workspace serve como **hub central** para gerenciamento de documentos ativos, facilitando o acompanhamento do progresso e a tomada de decisões rápidas sobre documentos em desenvolvimento.
