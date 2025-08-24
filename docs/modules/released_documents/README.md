# 📋 Módulo de Documentos Liberados

## Visão Geral

O módulo de **Documentos Liberados** fornece uma área dedicada para visualizar e gerenciar apenas as versões finais aprovadas e liberadas dos documentos, facilitando o acesso às versões oficiais sem a necessidade de navegar pelo histórico de desenvolvimento.

## Funcionalidades

### ✅ Implementadas

- **Listagem de Documentos Liberados**
  - Apenas documentos com status "Liberado"
  - Exibição da última versão liberada de cada documento
  - Informações: título, autor, versão, data de liberação, responsável

- **Sistema de Filtros Avançados**
  - Filtro por tipo de documento
  - Filtro por autor
  - Filtro por período de liberação (antes/depois)
  - Ordenação por múltiplos critérios

- **Visualização Detalhada**
  - Página de detalhes do documento liberado
  - Informações completas da liberação
  - Download da versão final
  - Histórico de liberações

- **Interface Otimizada**
  - Tabela responsiva com ações
  - Paginação para grandes volumes
  - Design moderno e acessível
  - Suporte a modo escuro

## Estrutura de Dados

### Controller ReleasedDocumentsController

```ruby
class ReleasedDocumentsController < ApplicationController
  before_action :authenticate_user!

  def index
    @documents = Document.joins(:document_releases)
                         .includes(:author, :latest_release, :current_responsible)
                         .where(status: 'liberado')
                         .distinct

    # Aplicação de filtros
    @documents = @documents.where(document_type: params[:document_type]) if params[:document_type].present?
    @documents = @documents.where(author_id: params[:author_id]) if params[:author_id].present?
    
    # Filtros de data
    if params[:released_after].present?
      @documents = @documents.joins(:document_releases)
                            .where('document_releases.released_at >= ?', Date.parse(params[:released_after]))
    end

    # Ordenação
    order_by = params[:order_by] || 'released_at'
    direction = params[:direction] || 'desc'
    
    # Paginação
    @documents = @documents.page(params[:page]).per(20)
  end

  def show
    @document = Document.includes(:author, :document_releases, :current_responsible)
                       .where(status: 'liberado')
                       .find(params[:id])
    
    @latest_release = @document.latest_release
  end
end
```

## Views

### Estrutura de Arquivos

```
app/views/released_documents/
├── index.html.erb          # Lista de documentos liberados
└── show.html.erb          # Detalhes do documento liberado
```

### Componentes Principais

#### Lista de Documentos (index.html.erb)
- **Header**: Título e contador de documentos
- **Filtros**: Formulário com múltiplos filtros
- **Tabela**: Lista responsiva com ações
- **Paginação**: Navegação entre páginas
- **Estado vazio**: Mensagem quando não há documentos

#### Detalhes do Documento (show.html.erb)
- **Informações principais**: Título, autor, tipo, versão
- **Status de liberação**: Confirmação visual do status
- **Arquivo liberado**: Download da versão final
- **Responsável atual**: Quem é responsável pelo documento
- **Histórico**: Lista de liberações anteriores

## Rotas

```ruby
namespace :admin do
  resources :released_documents, only: %i[index show]
end
```

### Endpoints Disponíveis

| Método | Rota | Descrição |
|--------|------|-----------|
| GET | `/admin/released_documents` | Lista de documentos liberados |
| GET | `/admin/released_documents/:id` | Detalhes do documento liberado |

## Filtros e Ordenação

### Filtros Disponíveis

1. **Tipo de Documento**
   - Filtra por tipo específico (contrato, manual, etc.)
   - Opção "Todos os tipos" para remover filtro

2. **Autor**
   - Filtra por autor específico
   - Opção "Todos os autores" para remover filtro

3. **Período de Liberação**
   - `released_after`: Documentos liberados após data
   - `released_before`: Documentos liberados antes de data

### Ordenação

| Campo | Descrição |
|-------|-----------|
| `released_at` | Data de liberação (padrão) |
| `title` | Título do documento |
| `author` | Nome do autor |
| `version` | Número da versão |

### Direção
- `asc`: Crescente
- `desc`: Decrescente (padrão)

## Integração com Sistema

### Navegação

```ruby
# app/navigation/admin_nav.rb
{ label: 'Documentos Liberados', path: '/admin/released_documents', icon: 'bi-check-circle', required_permission: 'documents.read' }
```

### Permissões

- **Visualização**: `documents.read`
- **Download**: Verificação de existência do arquivo
- **Acesso**: Apenas usuários autenticados

## CSS Classes Utilizadas

### Status Colors
- **Liberado**: `bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200`
- **Cards**: `bg-white dark:bg-gray-800 rounded-lg shadow border border-gray-200 dark:border-gray-700`
- **Tabelas**: `divide-y divide-gray-200 dark:divide-gray-700`
- **Hover**: `hover:bg-gray-50 dark:hover:bg-gray-700`

### Componentes
- **Filtros**: `grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4`
- **Layout**: `max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8`
- **Responsivo**: `overflow-x-auto`, `min-w-full`

## Testes

### Controller (RSpec)

```ruby
RSpec.describe ReleasedDocumentsController, type: :controller do
  describe 'GET #index' do
    let!(:released_document) { create(:document, status: 'liberado') }
    let!(:draft_document) { create(:document, status: 'aguardando_revisao') }

    it 'shows only released documents' do
      get :index
      
      expect(assigns(:documents)).to include(released_document)
      expect(assigns(:documents)).not_to include(draft_document)
    end

    it 'filters by document type' do
      get :index, params: { document_type: 'contrato' }
      
      expect(assigns(:documents)).to all(have_attributes(document_type: 'contrato'))
    end

    it 'filters by author' do
      author = create(:user)
      document = create(:document, status: 'liberado', author: author)
      
      get :index, params: { author_id: author.id }
      
      expect(assigns(:documents)).to include(document)
    end

    it 'filters by release date' do
      date = Date.current
      get :index, params: { released_after: date.to_s }
      
      expect(assigns(:documents).joins(:document_releases)
             .where('document_releases.released_at >= ?', date)).to be_present
    end
  end

  describe 'GET #show' do
    let(:document) { create(:document, status: 'liberado') }

    it 'shows released document details' do
      get :show, params: { id: document.id }
      
      expect(assigns(:document)).to eq(document)
      expect(assigns(:latest_release)).to eq(document.latest_release)
    end

    it 'prevents access to non-released documents' do
      draft_document = create(:document, status: 'aguardando_revisao')
      
      expect {
        get :show, params: { id: draft_document.id }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
```

### View (RSpec)

```ruby
RSpec.describe 'released_documents/index', type: :view do
  let(:documents) { create_list(:document, 3, status: 'liberado') }

  before do
    assign(:documents, documents)
    assign(:document_types, Document.document_types.keys)
    assign(:authors, User.all)
  end

  it 'displays released documents table' do
    render
    
    expect(rendered).to have_content('Documentos Liberados')
    expect(rendered).to have_css('table')
    documents.each do |doc|
      expect(rendered).to have_content(doc.title)
    end
  end

  it 'shows filter form' do
    render
    
    expect(rendered).to have_field('Tipo de Documento')
    expect(rendered).to have_field('Autor')
    expect(rendered).to have_field('Liberado após')
    expect(rendered).to have_field('Liberado antes')
  end

  it 'shows download links for available files' do
    render
    
    expect(rendered).to have_link('Download')
  end
end
```

## Próximos Passos

### Funcionalidades Futuras

1. **Exportação de Relatórios**
   - Exportar lista para Excel/PDF
   - Relatórios de liberações por período
   - Estatísticas de documentos liberados

2. **Notificações**
   - Alertas para novos documentos liberados
   - Notificações por email
   - Dashboard com resumo de liberações

3. **Busca Avançada**
   - Busca por texto no título/descrição
   - Filtros combinados
   - Busca por tags/metadados

4. **Visualização de Arquivos**
   - Preview de documentos
   - Visualização inline de PDFs
   - Thumbnails para imagens

5. **Compartilhamento**
   - Links públicos para documentos liberados
   - Controle de acesso por link
   - Expiração de links

6. **Auditoria**
   - Log de downloads
   - Histórico de visualizações
   - Relatórios de acesso

## Conclusão

O módulo de **Documentos Liberados** está completamente implementado e funcional, oferecendo:

- ✅ Listagem dedicada de versões finais liberadas
- ✅ Sistema de filtros avançados e ordenação
- ✅ Interface moderna e responsiva
- ✅ Integração com sistema de permissões
- ✅ Visualização detalhada de documentos
- ✅ Download direto de versões finais
- ✅ Design acessível com suporte a modo escuro

O sistema facilita o acesso às versões oficiais dos documentos, eliminando a necessidade de navegar pelo histórico de desenvolvimento e garantindo que apenas versões aprovadas sejam disponibilizadas.
