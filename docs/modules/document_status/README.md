# 📊 Módulo de Controle de Status de Documentos

## Visão Geral

O módulo de **Controle de Status de Documentos** gerencia o ciclo de vida completo dos documentos através de um sistema de status controlado, com histórico detalhado de todas as mudanças e transições permitidas.

## Funcionalidades

### ✅ Implementadas

- **Sistema de Status Controlado**
  - 4 status possíveis: Aguardando Revisão, Aguardando Correções, Aguardando Liberação, Liberado
  - Transições controladas entre status
  - Validação de transições permitidas

- **Histórico Completo de Mudanças**
  - Registro de todas as alterações de status
  - Quem fez a alteração e quando
  - Observações opcionais para cada mudança
  - Timeline visual das mudanças

- **Interface de Controle**
  - Formulário para alterar status
  - Visualização de transições disponíveis
  - Histórico em timeline
  - Integração com sistema de permissões

- **Validações de Negócio**
  - Apenas usuários com permissão de edição podem alterar status
  - Transições controladas por regras de negócio
  - Registro automático de logs

## Estrutura de Dados

### Modelo DocumentStatusLog

```ruby
class DocumentStatusLog < ApplicationRecord
  belongs_to :document
  belongs_to :user

  enum :old_status, Document.statuses, prefix: :old
  enum :new_status, Document.statuses, prefix: :new

  validates :old_status, presence: true
  validates :new_status, presence: true
  validates :user, presence: true

  scope :ordered, -> { order(created_at: :desc) }
end
```

### Campos da Tabela

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `document_id` | integer | Referência ao documento |
| `old_status` | integer | Status anterior |
| `new_status` | integer | Novo status |
| `user_id` | integer | Usuário que fez a alteração |
| `notes` | text | Observações da mudança (opcional) |

## Fluxo de Status

### Estados Possíveis

1. **🔍 Aguardando Revisão** (Status inicial)
   - Documento foi enviado e aguarda revisão
   - Pode ir para: Aguardando Correções, Aguardando Liberação

2. **⚠️ Aguardando Correções**
   - Revisor solicitou correções
   - Pode ir para: Aguardando Revisão

3. **⏳ Aguardando Liberação**
   - Documento foi aprovado, aguarda liberação final
   - Pode ir para: Liberado, Aguardando Revisão

4. **✅ Liberado**
   - Documento foi liberado como versão final
   - Pode ir para: Aguardando Revisão (se houver nova versão)

### Transições Permitidas

```ruby
def can_transition_to?(target_status)
  case status
  when 'aguardando_revisao'
    %w[aguardando_correcoes aguardando_liberacao].include?(target_status)
  when 'aguardando_correcoes'
    %w[aguardando_revisao].include?(target_status)
  when 'aguardando_liberacao'
    %w[liberado aguardando_revisao].include?(target_status)
  when 'liberado'
    %w[aguardando_revisao].include?(target_status)
  else
    false
  end
end
```

## Controllers

### DocumentStatusChangesController

```ruby
class DocumentStatusChangesController < ApplicationController
  before_action :set_document
  before_action :ensure_can_edit_document

  def index
    @status_logs = @document.document_status_logs.includes(:user).ordered
  end

  def new
    @available_transitions = @document.available_status_transitions
  end

  def create
    new_status = params[:document][:status]
    notes = params[:document][:status_notes]

    unless @document.can_transition_to?(new_status)
      redirect_to @document, alert: 'Transição de status não permitida.'
      return
    end

    @document.update_status!(new_status, current_user, notes)
    redirect_to @document, notice: "Status alterado para #{@document.status.humanize} com sucesso."
  end
end
```

## Views

### Estrutura de Arquivos

```
app/views/document_status_changes/
├── index.html.erb          # Histórico de mudanças
└── new.html.erb           # Formulário de alteração
```

### Componentes Principais

#### Formulário de Alteração (new.html.erb)
- Exibição do status atual
- Seleção de novo status com radio buttons
- Campo para observações
- Validação de transições permitidas

#### Histórico de Mudanças (index.html.erb)
- Timeline visual das mudanças
- Detalhes de cada alteração
- Observações quando disponíveis
- Status atual em destaque

## Métodos do Modelo

### Document

```ruby
# Alterar status com log automático
def update_status!(new_status, user, notes = nil)
  old_status = self.status
  return if old_status == new_status

  update!(status: new_status)
  
  document_status_logs.create!(
    old_status: old_status,
    new_status: new_status,
    user: user,
    notes: notes
  )
end

# Verificar se transição é permitida
def can_transition_to?(target_status)
  # Lógica de validação de transições
end

# Obter transições disponíveis
def available_status_transitions
  # Lista de status para onde pode ir
end

# Cores para cada status
def status_color
  case status
  when 'aguardando_revisao'   then 'text-yellow-600 bg-yellow-50 border-yellow-200'
  when 'aguardando_correcoes' then 'text-red-600 bg-red-50 border-red-200'
  when 'aguardando_liberacao' then 'text-orange-600 bg-orange-50 border-orange-200'
  when 'liberado'             then 'text-green-600 bg-green-50 border-green-200'
  end
end

# Ícones para cada status
def status_icon
  case status
  when 'aguardando_revisao'   then '🔍'
  when 'aguardando_correcoes' then '⚠️'
  when 'aguardando_liberacao' then '⏳'
  when 'liberado'             then '✅'
  end
end
```

### DocumentStatusLog

```ruby
# Descrição da mudança
def status_change_description
  case new_status
  when 'aguardando_revisao'   then 'Documento enviado para revisão'
  when 'aguardando_correcoes' then 'Correções solicitadas'
  when 'aguardando_liberacao' then 'Documento aprovado, aguardando liberação'
  when 'liberado'             then 'Documento liberado como versão final'
  end
end

# Cores e ícones para exibição
def status_color
  # Cores específicas para cada status
end

def status_icon
  # Ícones específicos para cada status
end
```

## Rotas

```ruby
resources :documents do
  resources :document_status_changes, only: %i[index new create]
end
```

### Endpoints Disponíveis

| Método | Rota | Descrição |
|--------|------|-----------|
| GET | `/admin/documents/:id/status_changes` | Histórico de mudanças |
| GET | `/admin/documents/:id/status_changes/new` | Formulário de alteração |
| POST | `/admin/documents/:id/status_changes` | Alterar status |

## Segurança e Permissões

### Verificação de Acesso

```ruby
def ensure_can_edit_document
  return if @document.user_can_edit?(current_user)

  redirect_to @document, alert: 'Você não tem permissão para alterar o status deste documento.'
end
```

**Regras:**
- Apenas usuários com permissão de **editar** podem alterar status
- Verificação em todas as ações do controller
- Validação de transições permitidas
- Registro automático de quem fez a alteração

## Integração com Documentos

### Link na View de Show

```erb
<div class="flex items-center gap-2">
  <span class="inline-flex items-center px-2 py-1 text-xs font-semibold rounded-full <%= @document.status_color %>">
    <%= @document.status_icon %> <%= @document.status.humanize %>
  </span>
  <% if @document.user_can_edit?(current_user) %>
    <%= link_to new_admin_document_document_status_change_path(@document), 
        class: "text-blue-600 hover:text-blue-900 text-xs" do %>
      Alterar
    <% end %>
  <% end %>
</div>
```

### Link na Sidebar

```erb
<%= link_to admin_document_document_status_changes_path(@document), 
    class: "px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50" do %>
  Status
<% end %>
```

## CSS Classes Utilizadas

### Status Colors
- **Aguardando Revisão**: `text-yellow-600 bg-yellow-50 border-yellow-200`
- **Aguardando Correções**: `text-red-600 bg-red-50 border-red-200`
- **Aguardando Liberação**: `text-orange-600 bg-orange-50 border-orange-200`
- **Liberado**: `text-green-600 bg-green-50 border-green-200`

### Componentes
- **Timeline**: `flow-root`, `relative`, `ring-8`
- **Cards**: `bg-white dark:bg-gray-800 rounded-lg shadow border border-gray-200 dark:border-gray-700`
- **Formulários**: `space-y-6`, `grid grid-cols-1 gap-3`

## Testes

### Modelo (RSpec)

```ruby
RSpec.describe Document, type: :model do
  describe 'status transitions' do
    let(:document) { create(:document, status: 'aguardando_revisao') }
    let(:user) { create(:user) }

    it 'allows valid transitions' do
      expect(document.can_transition_to?('aguardando_correcoes')).to be true
      expect(document.can_transition_to?('aguardando_liberacao')).to be true
    end

    it 'prevents invalid transitions' do
      expect(document.can_transition_to?('liberado')).to be false
    end

    it 'creates status log when updating status' do
      expect {
        document.update_status!('aguardando_correcoes', user, 'Correções necessárias')
      }.to change(DocumentStatusLog, :count).by(1)
    end
  end
end
```

### Controller (RSpec)

```ruby
RSpec.describe DocumentStatusChangesController, type: :controller do
  describe 'POST #create' do
    context 'with valid transition' do
      it 'updates document status' do
        post :create, params: { 
          document_id: document.id, 
          document: { status: 'aguardando_correcoes', status_notes: 'Correções necessárias' }
        }
        
        expect(document.reload.status).to eq('aguardando_correcoes')
      end
    end

    context 'with invalid transition' do
      it 'prevents status change' do
        post :create, params: { 
          document_id: document.id, 
          document: { status: 'liberado' }
        }
        
        expect(response).to redirect_to(document)
        expect(flash[:alert]).to include('Transição de status não permitida')
      end
    end
  end
end
```

## Próximos Passos

### Funcionalidades Futuras

1. **Notificações Automáticas**
   - Email quando status é alterado
   - Notificação para responsáveis
   - Alertas para status críticos

2. **Workflow Avançado**
   - Aprovações em múltiplos níveis
   - Revisores específicos por status
   - Prazos para cada status

3. **Relatórios de Status**
   - Dashboard de documentos por status
   - Tempo médio em cada status
   - Análise de gargalos

4. **Automação**
   - Mudança automática de status baseada em ações
   - Triggers para liberação automática
   - Integração com sistema de tarefas

5. **Auditoria Avançada**
   - Logs detalhados de todas as ações
   - Relatórios de auditoria
   - Compliance e rastreabilidade

## Conclusão

O módulo de **Controle de Status de Documentos** está completamente implementado e funcional, oferecendo:

- ✅ Sistema de status controlado com transições validadas
- ✅ Histórico completo de mudanças com timeline visual
- ✅ Interface moderna para alteração de status
- ✅ Integração com sistema de permissões
- ✅ Validações de negócio robustas
- ✅ Design responsivo e acessível
- ✅ Suporte a modo escuro

O sistema garante que o ciclo de vida dos documentos seja controlado e rastreável, proporcionando transparência e controle total sobre o processo de revisão e liberação.
