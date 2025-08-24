# 👥 Módulo de Responsáveis por Status

## Visão Geral

O módulo de **Responsáveis por Status** permite atribuir usuários responsáveis por cada status do documento, facilitando o controle e acompanhamento de quem é responsável por cada etapa do ciclo de vida do documento.

## Funcionalidades

### ✅ Implementadas

- **Atribuição de Responsáveis**
  - Um responsável por status
  - Validação de unicidade por status
  - Interface para atribuir/remover responsáveis

- **Visualização de Responsáveis**
  - Lista de todos os responsáveis atribuídos
  - Indicação do responsável ativo (status atual)
  - Histórico de atribuições

- **Integração com Status**
  - Exibição do responsável atual no documento
  - Links para gerenciar responsáveis
  - Controle de permissões

## Estrutura de Dados

### Modelo DocumentResponsible

```ruby
class DocumentResponsible < ApplicationRecord
  belongs_to :document
  belongs_to :user

  enum :status, Document.statuses

  validates :status, presence: true
  validates :user, presence: true
  validates :document_id, uniqueness: { scope: :status }

  scope :for_status, ->(status) { where(status: status) }
  scope :ordered, -> { order(created_at: :desc) }
end
```

### Campos da Tabela

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `document_id` | integer | Referência ao documento |
| `status` | integer | Status do documento |
| `user_id` | integer | Usuário responsável |
| `created_at` | datetime | Data de atribuição |

## Controllers

### DocumentResponsiblesController

```ruby
class DocumentResponsiblesController < ApplicationController
  before_action :set_document
  before_action :ensure_can_edit_document

  def index
    @responsibles = @document.document_responsibles.includes(:user).ordered
    @available_users = User.all
  end

  def create
    user = User.find(params[:document_responsible][:user_id])
    status = params[:document_responsible][:status]

    @document.assign_responsible(user, status)
    redirect_to admin_document_document_responsibles_path(@document), 
                notice: "Responsável atribuído com sucesso."
  end

  def destroy
    responsible = @document.document_responsibles.find(params[:id])
    responsible.destroy
    
    redirect_to admin_document_document_responsibles_path(@document), 
                notice: "Responsável removido com sucesso."
  end
end
```

## Views

### Estrutura de Arquivos

```
app/views/document_responsibles/
└── index.html.erb          # Gerenciamento de responsáveis
```

### Componentes Principais

#### Gerenciamento de Responsáveis (index.html.erb)
- Status atual do documento
- Formulário para atribuir responsável
- Lista de responsáveis atribuídos
- Ações para remover responsáveis

## Métodos do Modelo

### Document

```ruby
# Obter responsável atual
def current_responsible
  document_responsibles.for_status(status).first&.user
end

# Atribuir responsável
def assign_responsible(user, status = nil)
  target_status = status || self.status
  
  document_responsibles.find_or_initialize_by(status: target_status).tap do |responsible|
    responsible.user = user
    responsible.save!
  end
end

# Remover responsável
def remove_responsible(status = nil)
  target_status = status || self.status
  document_responsibles.for_status(target_status).destroy_all
end

# Obter responsável para status específico
def responsible_for_status(status)
  document_responsibles.for_status(status).first&.user
end
```

## Rotas

```ruby
resources :documents do
  resources :document_responsibles, only: %i[index create destroy]
end
```

### Endpoints Disponíveis

| Método | Rota | Descrição |
|--------|------|-----------|
| GET | `/admin/documents/:id/responsibles` | Listar responsáveis |
| POST | `/admin/documents/:id/responsibles` | Atribuir responsável |
| DELETE | `/admin/documents/:id/responsibles/:id` | Remover responsável |

## Segurança e Permissões

### Verificação de Acesso

```ruby
def ensure_can_edit_document
  return if @document.user_can_edit?(current_user)

  redirect_to @document, alert: 'Você não tem permissão para gerenciar responsáveis deste documento.'
end
```

**Regras:**
- Apenas usuários com permissão de **editar** podem gerenciar responsáveis
- Verificação em todas as ações do controller
- Validação de unicidade por status

## Integração com Documentos

### Exibição do Responsável Atual

```erb
<% if @document.current_responsible %>
  <p class="text-xs text-gray-500 mt-1">
    Responsável: <%= @document.current_responsible.name %>
  </p>
<% end %>
```

### Link na Sidebar

```erb
<%= link_to admin_document_document_responsibles_path(@document), 
    class: "px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50" do %>
  Responsáveis
<% end %>
```

## CSS Classes Utilizadas

### Status Colors
- **Ativo**: `bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200`
- **Cards**: `bg-white dark:bg-gray-800 rounded-lg shadow border border-gray-200 dark:border-gray-700`
- **Formulários**: `grid grid-cols-1 md:grid-cols-2 gap-4`

## Testes

### Modelo (RSpec)

```ruby
RSpec.describe Document, type: :model do
  describe 'responsibles' do
    let(:document) { create(:document) }
    let(:user) { create(:user) }

    it 'assigns responsible for status' do
      expect {
        document.assign_responsible(user, 'aguardando_revisao')
      }.to change(DocumentResponsible, :count).by(1)
    end

    it 'returns current responsible' do
      document.assign_responsible(user, 'aguardando_revisao')
      expect(document.current_responsible).to eq(user)
    end

    it 'prevents duplicate responsible for same status' do
      document.assign_responsible(user, 'aguardando_revisao')
      another_user = create(:user)
      
      expect {
        document.assign_responsible(another_user, 'aguardando_revisao')
      }.to change(DocumentResponsible, :count).by(0)
    end
  end
end
```

### Controller (RSpec)

```ruby
RSpec.describe DocumentResponsiblesController, type: :controller do
  describe 'POST #create' do
    it 'assigns responsible' do
      post :create, params: { 
        document_id: document.id, 
        document_responsible: { user_id: user.id, status: 'aguardando_revisao' }
      }
      
      expect(document.reload.current_responsible).to eq(user)
    end
  end
end
```

## Próximos Passos

### Funcionalidades Futuras

1. **Notificações Automáticas**
   - Email quando responsável é atribuído
   - Notificação para responsável atual
   - Alertas para responsabilidades pendentes

2. **Workflow Avançado**
   - Múltiplos responsáveis por status
   - Hierarquia de responsáveis
   - Delegação de responsabilidades

3. **Relatórios de Responsabilidade**
   - Dashboard de responsabilidades
   - Tempo médio de resposta
   - Análise de performance

4. **Automação**
   - Atribuição automática baseada em regras
   - Rotação de responsáveis
   - Escalação automática

## Conclusão

O módulo de **Responsáveis por Status** está completamente implementado e funcional, oferecendo:

- ✅ Atribuição controlada de responsáveis por status
- ✅ Interface intuitiva para gerenciar responsáveis
- ✅ Integração com sistema de permissões
- ✅ Validações de negócio robustas
- ✅ Design responsivo e acessível
- ✅ Suporte a modo escuro

O sistema garante que cada etapa do documento tenha um responsável claro, facilitando o acompanhamento e controle do processo.
