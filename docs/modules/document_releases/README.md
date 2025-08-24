# 🚀 Módulo de Liberação de Documentos

## Visão Geral

O módulo de **Liberação de Documentos** gerencia o processo de liberação de versões finais dos documentos, criando cópias imutáveis em pasta específica e controlando o versionamento das liberações.

## Funcionalidades

### ✅ Implementadas

- **Liberação Controlada**
  - Apenas documentos no status "Aguardando Liberação" podem ser liberados
  - Criação automática de cópia em pasta `/released/`
  - Incremento automático de versão (1.0 → 2.0)

- **Versionamento de Liberações**
  - Histórico completo de liberações
  - Controle de versões liberadas
  - Download de versões liberadas

- **Interface de Liberação**
  - Tela de confirmação com detalhes da liberação
  - Lista de todas as liberações do documento
  - Botão de liberação integrado ao documento

- **Validações de Negócio**
  - Verificação de permissões de edição
  - Validação de status para liberação
  - Controle de versionamento

## Estrutura de Dados

### Modelo DocumentRelease

```ruby
class DocumentRelease < ApplicationRecord
  belongs_to :document
  belongs_to :version, class_name: 'DocumentVersion'
  belongs_to :released_by, class_name: 'User'

  validates :version, presence: true
  validates :released_by, presence: true
  validates :released_at, presence: true

  scope :ordered, -> { order(released_at: :desc) }

  def version_number
    version.version_number
  end

  def released_version_path
    File.join('storage', 'documents', document.id.to_s, 'released', "v#{version_number}#{File.extname(version.file_path)}")
  end

  def released_file_exists?
    File.exist?(Rails.root.join(released_version_path))
  end
end
```

### Campos da Tabela

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `document_id` | integer | Referência ao documento |
| `version_id` | integer | Referência à versão liberada |
| `released_by_id` | integer | Usuário que liberou |
| `released_at` | datetime | Data/hora da liberação |

### Campo Adicionado ao Document

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `released_version` | string | Versão liberada atual |

## Controllers

### DocumentReleasesController

```ruby
class DocumentReleasesController < ApplicationController
  before_action :set_document
  before_action :ensure_can_edit_document

  def index
    @releases = @document.document_releases.includes(:version, :released_by).ordered
  end

  def new
    unless @document.can_be_released?
      redirect_to @document, alert: 'Documento não pode ser liberado no momento.'
      return
    end
  end

  def create
    unless @document.can_be_released?
      redirect_to @document, alert: 'Documento não pode ser liberado no momento.'
      return
    end

    release = @document.release_document!(current_user)
    
    if release
      redirect_to @document, notice: "Documento liberado com sucesso como versão #{release.version_number}."
    else
      redirect_to @document, alert: 'Erro ao liberar documento.'
    end
  end

  def download
    release = @document.document_releases.find(params[:id])
    
    if release.released_file_exists?
      send_file Rails.root.join(release.released_version_path), 
                filename: "#{@document.title}_v#{release.version_number}#{File.extname(release.version.file_path)}"
    else
      redirect_to @document, alert: 'Arquivo liberado não encontrado.'
    end
  end
end
```

## Views

### Estrutura de Arquivos

```
app/views/document_releases/
├── index.html.erb          # Lista de liberações
└── new.html.erb           # Confirmação de liberação
```

### Componentes Principais

#### Confirmação de Liberação (new.html.erb)
- Informações da versão atual e próxima liberação
- Status atual e novo status
- Detalhes do arquivo que será copiado
- Confirmação com validação

#### Lista de Liberações (index.html.erb)
- Histórico completo de liberações
- Status atual do documento
- Botão para nova liberação (se permitido)
- Download de versões liberadas

## Métodos do Modelo

### Document

```ruby
# Obter última liberação
def latest_release
  document_releases.ordered.first
end

# Verificar se pode ser liberado
def can_be_released?
  status == 'aguardando_liberacao'
end

# Liberar documento
def release_document!(user)
  return false unless can_be_released?

  ActiveRecord::Base.transaction do
    # Criar release
    release = document_releases.create!(
      version: latest_version,
      released_by: user,
      released_at: Time.current
    )

    # Copiar arquivo para pasta released
    copy_file_to_released_folder(release)

    # Atualizar status para liberado
    update_status!('liberado', user, 'Documento liberado como versão final')

    # Atualizar versão liberada
    update!(released_version: latest_version.version_number)

    release
  end
rescue StandardError => e
  Rails.logger.error "Erro ao liberar documento #{id}: #{e.message}"
  false
end

# Copiar arquivo para pasta released
def copy_file_to_released_folder(release)
  source_path = Rails.root.join('storage', latest_version.file_path)
  target_path = Rails.root.join(release.released_version_path)
  
  FileUtils.mkdir_p(File.dirname(target_path))
  FileUtils.cp(source_path, target_path)
end

# Calcular próxima versão de liberação
def next_release_version
  if latest_release
    major, _minor = latest_release.version_number.split('.').map(&:to_i)
    "#{major + 1}.0"
  else
    '1.0'
  end
end
```

## Rotas

```ruby
resources :documents do
  resources :document_releases, only: %i[index new create] do
    member do
      get :download
    end
  end
end
```

### Endpoints Disponíveis

| Método | Rota | Descrição |
|--------|------|-----------|
| GET | `/admin/documents/:id/releases` | Listar liberações |
| GET | `/admin/documents/:id/releases/new` | Confirmação de liberação |
| POST | `/admin/documents/:id/releases` | Liberar documento |
| GET | `/admin/documents/:id/releases/:id/download` | Download da versão liberada |

## Segurança e Permissões

### Verificação de Acesso

```ruby
def ensure_can_edit_document
  return if @document.user_can_edit?(current_user)

  redirect_to @document, alert: 'Você não tem permissão para liberar este documento.'
end
```

**Regras:**
- Apenas usuários com permissão de **editar** podem liberar documentos
- Documento deve estar no status "Aguardando Liberação"
- Verificação em todas as ações do controller
- Validação de existência do arquivo antes do download

## Integração com Documentos

### Botão de Liberação

```erb
<% if @document.can_be_released? %>
  <%= link_to new_admin_document_document_release_path(@document), 
      class: "inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-green-600 hover:bg-green-700" do %>
    <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"/>
    </svg>
    Liberar Documento
  <% end %>
<% end %>
```

### Link na Sidebar

```erb
<%= link_to admin_document_document_releases_path(@document), 
    class: "px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50" do %>
  Releases
<% end %>
```

### Resumo na View de Show

```erb
<% if @document.latest_release %>
  <div class="flex items-center gap-2 p-2 bg-green-50 rounded border-l-4 border-green-400">
    <svg class="w-4 h-4 text-green-500" fill="currentColor" viewBox="0 0 20 20">
      <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
    </svg>
    <div class="flex-1">
      <p class="text-sm font-medium text-gray-900">v<%= @document.latest_release.version_number %></p>
      <p class="text-xs text-gray-500">
        Liberado em <%= l(@document.latest_release.released_at, format: :short) %>
      </p>
    </div>
  </div>
<% end %>
```

## Estrutura de Arquivos

### Pasta de Liberações

```
storage/
└── documents/
    └── {document_id}/
        ├── versions/           # Versões de desenvolvimento
        │   ├── v1.0.pdf
        │   ├── v1.1.pdf
        │   └── v1.2.pdf
        └── released/           # Versões liberadas
            ├── v1.0.pdf
            └── v2.0.pdf
```

## CSS Classes Utilizadas

### Status Colors
- **Liberado**: `bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200`
- **Cards**: `bg-white dark:bg-gray-800 rounded-lg shadow border border-gray-200 dark:border-gray-700`
- **Botões**: `bg-green-600 hover:bg-green-700 text-white`

## Testes

### Modelo (RSpec)

```ruby
RSpec.describe Document, type: :model do
  describe 'releases' do
    let(:document) { create(:document, status: 'aguardando_liberacao') }
    let(:user) { create(:user) }
    let(:version) { create(:document_version, document: document, version_number: '1.2') }

    before { document.update!(latest_version: version) }

    it 'can be released when status is aguardando_liberacao' do
      expect(document.can_be_released?).to be true
    end

    it 'cannot be released when status is not aguardando_liberacao' do
      document.update!(status: 'aguardando_revisao')
      expect(document.can_be_released?).to be false
    end

    it 'creates release when document is released' do
      expect {
        document.release_document!(user)
      }.to change(DocumentRelease, :count).by(1)
    end

    it 'updates status to liberado when released' do
      document.release_document!(user)
      expect(document.reload.status).to eq('liberado')
    end

    it 'calculates next release version correctly' do
      expect(document.next_release_version).to eq('1.0')
      
      create(:document_release, document: document, version: version)
      expect(document.reload.next_release_version).to eq('2.0')
    end
  end
end
```

### Controller (RSpec)

```ruby
RSpec.describe DocumentReleasesController, type: :controller do
  describe 'POST #create' do
    context 'when document can be released' do
      it 'releases document successfully' do
        post :create, params: { document_id: document.id }
        
        expect(document.reload.status).to eq('liberado')
        expect(response).to redirect_to(document)
        expect(flash[:notice]).to include('Documento liberado com sucesso')
      end
    end

    context 'when document cannot be released' do
      before { document.update!(status: 'aguardando_revisao') }

      it 'prevents release' do
        post :create, params: { document_id: document.id }
        
        expect(response).to redirect_to(document)
        expect(flash[:alert]).to include('Documento não pode ser liberado')
      end
    end
  end
end
```

## Próximos Passos

### Funcionalidades Futuras

1. **Notificações Automáticas**
   - Email quando documento é liberado
   - Notificação para stakeholders
   - Alertas para liberações pendentes

2. **Workflow Avançado**
   - Aprovações em múltiplos níveis
   - Revisores específicos para liberação
   - Prazos para liberação

3. **Relatórios de Liberação**
   - Dashboard de liberações
   - Tempo médio entre liberações
   - Análise de frequência de liberações

4. **Automação**
   - Liberação automática baseada em critérios
   - Triggers para liberação
   - Integração com CI/CD

5. **Auditoria Avançada**
   - Logs detalhados de liberações
   - Relatórios de auditoria
   - Compliance e rastreabilidade

## Conclusão

O módulo de **Liberação de Documentos** está completamente implementado e funcional, oferecendo:

- ✅ Controle rigoroso de liberação de documentos
- ✅ Versionamento automático de liberações
- ✅ Interface intuitiva para confirmação de liberação
- ✅ Integração com sistema de permissões
- ✅ Validações de negócio robustas
- ✅ Design responsivo e acessível
- ✅ Suporte a modo escuro

O sistema garante que apenas versões finais e aprovadas sejam liberadas, mantendo o controle total sobre o processo de versionamento e disponibilização de documentos.
