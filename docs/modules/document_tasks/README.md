# 📋 Módulo de Tarefas de Documentos

## Visão Geral

O módulo de **Tarefas de Documentos** permite criar e gerenciar listas de tarefas vinculadas a cada documento do sistema. Cada tarefa pode ter prioridade, responsável, descrição e status de conclusão.

## Funcionalidades

### ✅ Implementadas

- **CRUD Completo de Tarefas**
  - Criar, editar, visualizar e excluir tarefas
  - Validações de campos obrigatórios
  - Relacionamento com documentos e usuários

- **Sistema de Prioridades**
  - Alta (🔴), Média (🟡), Baixa (🟢)
  - Cores visuais diferenciadas para cada prioridade
  - Ordenação automática por prioridade

- **Atribuição de Responsáveis**
  - Seleção de usuário responsável pela tarefa
  - Campo opcional (pode ser criada sem responsável)
  - Exibição do responsável nos cards de tarefa

- **Controle de Status**
  - Marcar tarefa como concluída
  - Reabrir tarefa concluída
  - Registro de quem concluiu e quando
  - Filtros por status (Todas, Pendentes, Concluídas)

- **Interface Moderna**
  - Cards visuais para cada tarefa
  - Filtros interativos com Stimulus
  - Design responsivo com Tailwind CSS
  - Suporte a modo escuro

- **Integração com Documentos**
  - Link "Tarefas" na view de show do documento
  - Resumo das tarefas na sidebar do documento
  - Verificação de permissões de edição

## Estrutura de Dados

### Modelo DocumentTask

```ruby
class DocumentTask < ApplicationRecord
  belongs_to :document
  belongs_to :created_by, class_name: 'User'
  belongs_to :assigned_to, class_name: 'User', optional: true
  belongs_to :completed_by, class_name: 'User', optional: true

  enum priority: { low: 0, medium: 1, high: 2 }

  validates :title, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 1000 }
  validates :priority, presence: true

  scope :pending, -> { where(completed_at: nil) }
  scope :completed, -> { where.not(completed_at: nil) }
  scope :by_priority, -> { order(priority: :desc) }
end
```

### Campos da Tabela

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `document_id` | integer | Referência ao documento |
| `title` | string | Título da tarefa (obrigatório) |
| `description` | text | Descrição detalhada (opcional) |
| `priority` | integer | Prioridade (0=baixa, 1=média, 2=alta) |
| `created_by_id` | integer | Usuário que criou a tarefa |
| `assigned_to_id` | integer | Usuário responsável (opcional) |
| `completed_by_id` | integer | Usuário que concluiu (opcional) |
| `completed_at` | datetime | Data/hora da conclusão |

## Controllers

### DocumentTasksController

```ruby
class DocumentTasksController < ApplicationController
  before_action :set_document
  before_action :set_task, only: [:show, :edit, :update, :destroy, :complete, :reopen]
  before_action :ensure_can_edit_document

  def index
    @tasks = @document.document_tasks.includes(:created_by, :assigned_to, :completed_by)
    @pending_tasks = @tasks.pending.by_priority
    @completed_tasks = @tasks.completed.order(completed_at: :desc)
  end

  def create
    @task = @document.document_tasks.build(task_params)
    @task.created_by = current_user
    # ...
  end

  def complete
    @task.complete!(current_user)
    # ...
  end

  def reopen
    @task.reopen!
    # ...
  end
end
```

## Views

### Estrutura de Arquivos

```
app/views/document_tasks/
├── index.html.erb          # Lista principal de tarefas
├── new.html.erb           # Formulário de nova tarefa
├── edit.html.erb          # Formulário de edição
└── _task_card.html.erb    # Partial do card de tarefa
```

### Componentes Principais

#### Lista de Tarefas (index.html.erb)
- Filtros por status (Todas, Pendentes, Concluídas)
- Seções separadas para tarefas pendentes e concluídas
- Contador de tarefas em cada filtro
- Botão para criar nova tarefa

#### Card de Tarefa (_task_card.html.erb)
- Checkbox para marcar como concluída
- Título e descrição da tarefa
- Badge de prioridade com ícone e cor
- Metadados (criado por, responsável, datas)
- Ações (editar, excluir)

#### Formulários (new.html.erb, edit.html.erb)
- Campo de título (obrigatório)
- Campo de descrição (opcional)
- Seleção de prioridade com radio buttons
- Dropdown para selecionar responsável
- Validações e mensagens de erro

## JavaScript (Stimulus)

### TaskFilterController

```javascript
export default class extends Controller {
  static targets = ["section", "button"]

  filter(event) {
    const status = event.currentTarget.dataset.taskFilterStatusValue
    
    // Atualiza botões ativos
    this.updateButtonStates(status)
    
    // Mostra/esconde seções
    this.toggleSections(status)
  }
}
```

**Funcionalidades:**
- Filtro dinâmico por status
- Atualização visual dos botões ativos
- Mostrar/ocultar seções de tarefas
- Transições suaves

## Rotas

```ruby
resources :documents do
  resources :document_tasks, except: [:show] do
    member do
      patch :complete
      patch :reopen
    end
  end
end
```

### Endpoints Disponíveis

| Método | Rota | Descrição |
|--------|------|-----------|
| GET | `/admin/documents/:id/tasks` | Lista de tarefas |
| GET | `/admin/documents/:id/tasks/new` | Formulário nova tarefa |
| POST | `/admin/documents/:id/tasks` | Criar tarefa |
| GET | `/admin/documents/:id/tasks/:id/edit` | Formulário edição |
| PATCH | `/admin/documents/:id/tasks/:id` | Atualizar tarefa |
| DELETE | `/admin/documents/:id/tasks/:id` | Excluir tarefa |
| PATCH | `/admin/documents/:id/tasks/:id/complete` | Marcar como concluída |
| PATCH | `/admin/documents/:id/tasks/:id/reopen` | Reabrir tarefa |

## Segurança e Permissões

### Verificação de Acesso

```ruby
def ensure_can_edit_document
  unless @document.user_can_edit?(current_user)
    redirect_to @document, alert: 'Você não tem permissão para gerenciar tarefas deste documento.'
  end
end
```

**Regras:**
- Apenas usuários com permissão de **editar** podem gerenciar tarefas
- Verificação em todas as ações do controller
- Redirecionamento com mensagem de erro se não autorizado

## Integração com Documentos

### Link na View de Show

```erb
<%= link_to admin_document_document_tasks_path(@document), class: "..." do %>
  Tarefas
<% end %>
```

### Resumo na Sidebar

```erb
<div class="bg-white shadow-md rounded-lg p-6 mb-6">
  <h2 class="text-xl font-semibold text-gray-900">Tarefas</h2>
  
  <% pending_tasks = @document.document_tasks.pending.limit(3) %>
  <% completed_tasks = @document.document_tasks.completed.limit(2) %>
  
  <!-- Exibição das tarefas pendentes e concluídas -->
</div>
```

## Métodos do Modelo

### DocumentTask

```ruby
# Verificar se está concluída
def completed?
  completed_at.present?
end

# Marcar como concluída
def complete!(user)
  update!(
    completed_by: user,
    completed_at: Time.current
  )
end

# Reabrir tarefa
def reopen!
  update!(
    completed_by: nil,
    completed_at: nil
  )
end

# Cores para prioridade
def priority_color
  case priority
  when 'high'   then 'text-red-600 bg-red-50 border-red-200'
  when 'medium' then 'text-yellow-600 bg-yellow-50 border-yellow-200'
  when 'low'    then 'text-green-600 bg-green-50 border-green-200'
  end
end

# Ícones para prioridade
def priority_icon
  case priority
  when 'high'   then '🔴'
  when 'medium' then '🟡'
  when 'low'    then '🟢'
  end
end
```

### Document

```ruby
# Relacionamento com tarefas
has_many :document_tasks, dependent: :destroy
```

## CSS Classes Utilizadas

### Prioridades
- **Alta**: `text-red-600 bg-red-50 border-red-200`
- **Média**: `text-yellow-600 bg-yellow-50 border-yellow-200`
- **Baixa**: `text-green-600 bg-green-50 border-green-200`

### Estados
- **Pendente**: `bg-yellow-50 border-l-4 border-yellow-400`
- **Concluída**: `bg-green-50 border-l-4 border-green-400`

### Componentes
- **Cards**: `bg-white dark:bg-gray-800 rounded-lg shadow border border-gray-200 dark:border-gray-700`
- **Botões**: `px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium`

## Testes

### Modelo (RSpec)

```ruby
RSpec.describe DocumentTask, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:priority) }
    it { should validate_length_of(:title).is_at_most(255) }
    it { should validate_length_of(:description).is_at_most(1000) }
  end

  describe 'associations' do
    it { should belong_to(:document) }
    it { should belong_to(:created_by).class_name('User') }
    it { should belong_to(:assigned_to).class_name('User').optional }
    it { should belong_to(:completed_by).class_name('User').optional }
  end

  describe 'scopes' do
    it 'filters pending tasks' do
      pending_task = create(:document_task, completed_at: nil)
      completed_task = create(:document_task, completed_at: Time.current)
      
      expect(DocumentTask.pending).to include(pending_task)
      expect(DocumentTask.pending).not_to include(completed_task)
    end
  end
end
```

### Controller (RSpec)

```ruby
RSpec.describe DocumentTasksController, type: :controller do
  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new task' do
        expect {
          post :create, params: { document_id: document.id, document_task: valid_attributes }
        }.to change(DocumentTask, :count).by(1)
      end
    end
  end

  describe 'PATCH #complete' do
    it 'marks task as completed' do
      patch :complete, params: { document_id: document.id, id: task.id }
      
      expect(task.reload.completed?).to be true
      expect(task.completed_by).to eq(user)
    end
  end
end
```

## Próximos Passos

### Funcionalidades Futuras

1. **Notificações**
   - Email quando tarefa é atribuída
   - Notificação quando tarefa é concluída
   - Lembretes para tarefas vencidas

2. **Datas de Vencimento**
   - Campo `due_date` para tarefas
   - Alertas de vencimento
   - Filtros por data

3. **Comentários em Tarefas**
   - Sistema de comentários por tarefa
   - Histórico de discussões
   - @mentions de usuários

4. **Templates de Tarefas**
   - Tarefas pré-definidas por tipo de documento
   - Criação em lote de tarefas
   - Importação de templates

5. **Relatórios**
   - Dashboard de produtividade
   - Relatórios de tarefas por usuário
   - Métricas de conclusão

## Conclusão

O módulo de **Tarefas de Documentos** está completamente implementado e funcional, oferecendo:

- ✅ Interface moderna e intuitiva
- ✅ Sistema completo de CRUD
- ✅ Controle de prioridades e responsáveis
- ✅ Filtros dinâmicos
- ✅ Integração com sistema de permissões
- ✅ Design responsivo
- ✅ Suporte a modo escuro

O sistema está pronto para uso em produção e pode ser facilmente estendido com novas funcionalidades conforme necessário.
