# 📋 Sistema de Permissões Avançado — Gestão de Documentos

## 🎯 Contexto e Problema Identificado

**Problemas críticos** identificados no sistema de permissões atual:

1. **Não consegue adicionar responsáveis** - há inconsistências entre modelos (User vs Professional)
2. **Permissões insuficientes** - falta controle granular sobre quem pode:
   - Acessar a tela de documentos
   - Ver documentos na listagem
   - Criar novos documentos
   - Ver documentos liberados
3. **Fluxo de permissões confuso** - não há separação clara entre:
   - Área de trabalho (documentos em andamento)
   - Área de documentos liberados
   - Permissões de criação vs visualização

## 🔧 Solução Proposta: Sistema de Permissões em 4 Níveis

### **Nível 1: Permissões de Admin (Global)**
```ruby
# Usuários em grupos admin têm acesso total
def admin?
  groups.any?(&:admin?)
end
```

### **Nível 2: Permissões de Grupo (Sistema)**
```ruby
# Permissões no sistema de grupos
- documents.access           # Pode acessar área de documentos
- documents.create          # Pode criar novos documentos
- documents.view_released   # Pode ver documentos liberados
- documents.assign_responsibles  # Pode atribuir responsáveis
- documents.release         # Pode liberar documentos
- documents.manage_permissions  # Pode gerenciar permissões
```

### **Nível 3: Permissões de Sistema (Professional)**
```ruby
# Novas permissões no modelo Professional
enum system_permissions: {
  can_access_documents: 0,      # Pode acessar área de documentos
  can_create_documents: 1,      # Pode criar novos documentos
  can_view_released: 2,         # Pode ver documentos liberados
  can_manage_permissions: 3,    # Pode gerenciar permissões de outros
  can_assign_responsibles: 4,   # Pode atribuir responsáveis
  can_release_documents: 5      # Pode liberar documentos
}
```

### **Nível 4: Permissões por Documento (Específicas)**
```ruby
# Permissões existentes (melhoradas)
enum access_level: {
  visualizar: 0,    # Pode ver documento
  comentar: 1,      # Pode comentar
  editar: 2,        # Pode editar e subir versões
  gerenciar: 3      # Pode gerenciar permissões e responsáveis
}
```

### **Nível 5: Responsabilidades (Atribuições)**
```ruby
# Corrigir modelo DocumentResponsible
class DocumentResponsible < ApplicationRecord
  belongs_to :document
  belongs_to :professional  # Corrigir: usar Professional, não User
  
  enum :status, Document.statuses
  validates :document_id, uniqueness: { scope: :status }
end
```

## 📋 Tarefas de Implementação

### **1. Correção do Modelo DocumentResponsible**
**Problema**: Inconsistência entre User e Professional nos responsáveis.

**Solução**:
- Corrigir modelo para usar `belongs_to :professional`
- Atualizar controller para trabalhar com Professional
- Corrigir views para exibir dados corretos
- Atualizar queries no WorkspaceController

**Arquivos a modificar**:
- `app/models/document_responsible.rb`
- `app/controllers/admin/document_responsibles_controller.rb`
- `app/views/admin/document_responsibles/index.html.erb`
- `app/controllers/admin/workspace_controller.rb`

### **2. Implementar Permissões de Sistema**
**Adicionar ao modelo Professional**:
```ruby
class Professional < ApplicationRecord
  # Novas permissões de sistema
  enum system_permissions: {
    can_access_documents: 0,
    can_create_documents: 1, 
    can_view_released: 2,
    can_manage_permissions: 3,
    can_assign_responsibles: 4,
    can_release_documents: 5
  }
  
  # Métodos de verificação
  def can_access_documents?
    system_permissions.include?('can_access_documents')
  end
  
  def can_create_documents?
    system_permissions.include?('can_create_documents')
  end
  
  def can_view_released?
    system_permissions.include?('can_view_released')
  end
end
```

**Migration necessária**:
```ruby
class AddSystemPermissionsToProfessionals < ActiveRecord::Migration[8.0]
  def change
    add_column :professionals, :system_permissions, :integer, array: true, default: []
    add_index :professionals, :system_permissions, using: 'gin'
  end
end
```

### **3. Atualizar Controllers com Verificações de Permissão**
**WorkspaceController**:
```ruby
class Admin::WorkspaceController < Admin::BaseController
  before_action :ensure_can_access_documents
  
  def index
    # Se não pode criar documentos, mostrar apenas onde é responsável
    if current_user.professional.can_create_documents?
      @documents = Document.includes(:author, :document_versions, :document_responsibles)
                           .where.not(status: 'liberado')
    else
      @documents = Document.joins(:document_responsibles)
                           .where(document_responsibles: { professional: current_user.professional })
                           .where.not(status: 'liberado')
    end
    
    # ... resto do código
  end
  
  private
  
  def ensure_can_access_documents
    unless current_user.professional.can_access_documents?
      redirect_to admin_dashboard_path, alert: 'Você não tem permissão para acessar documentos.'
    end
  end
end
```

**ReleasedDocumentsController**:
```ruby
class Admin::ReleasedDocumentsController < Admin::BaseController
  before_action :ensure_can_view_released
  
  def index
    # ... código existente
  end
  
  private
  
  def ensure_can_view_released
    unless current_user.professional.can_view_released?
      redirect_to admin_dashboard_path, alert: 'Você não tem permissão para ver documentos liberados.'
    end
  end
end
```

**DocumentsController**:
```ruby
class Admin::DocumentsController < Admin::BaseController
  before_action :ensure_can_create_documents, only: [:new, :create]
  before_action :ensure_can_assign_responsibles, only: [:assign_responsible]
  
  def new
    # ... código existente
  end
  
  private
  
  def ensure_can_create_documents
    unless current_user.professional.can_create_documents?
      redirect_to admin_workspace_path, alert: 'Você não tem permissão para criar documentos.'
    end
  end
  
  def ensure_can_assign_responsibles
    unless current_user.professional.can_assign_responsibles?
      redirect_to admin_document_path(@document), alert: 'Você não tem permissão para atribuir responsáveis.'
    end
  end
end
```

### **4. Atualizar Views com Controles de Acesso**
**Workspace (index.html.erb)**:
```erb
<!-- Botão "Novo Documento" só aparece para quem pode criar -->
<% if current_user.professional.can_create_documents? %>
  <%= link_to new_admin_document_path, class: "btn-primary" do %>
    <svg>...</svg>
    Novo Documento
  <% end %>
<% end %>

<!-- Filtro "Meus Documentos" só aparece para quem não pode criar -->
<% unless current_user.professional.can_create_documents? %>
  <div class="form-check">
    <%= f.check_box :my_documents, class: "form-check-input" %>
    <%= f.label :my_documents, "Apenas meus documentos", class: "form-check-label" %>
  </div>
<% end %>
```

**Released Documents (index.html.erb)**:
```erb
<!-- Tabela só mostra documentos se tem permissão -->
<% if current_user.professional.can_view_released? %>
  <!-- Tabela existente -->
<% else %>
  <div class="text-center py-8">
    <p class="text-gray-500">Você não tem permissão para ver documentos liberados.</p>
  </div>
<% end %>
```

### **5. Atualizar Navegação (Sidebar)**
**Layout Admin (sidebar)**:
```erb
<!-- Link para Workspace -->
<% if current_user.professional.can_access_documents? %>
  <%= link_to admin_workspace_path, class: "nav-link" do %>
    <svg>...</svg>
    Documentos
  <% end %>
<% end %>

<!-- Link para Documentos Liberados -->
<% if current_user.professional.can_view_released? %>
  <%= link_to admin_released_documents_path, class: "nav-link" do %>
    <svg>...</svg>
    Documentos Liberados
  <% end %>
<% end %>
```

### **6. Interface de Gerenciamento de Permissões**
**Nova tela: Admin > Usuários > Permissões**:
```ruby
# Controller
class Admin::ProfessionalPermissionsController < Admin::BaseController
  def index
    @professionals = Professional.all
  end
  
  def update
    @professional = Professional.find(params[:id])
    @professional.update(system_permissions: params[:system_permissions])
    redirect_to admin_professional_permissions_path, notice: 'Permissões atualizadas!'
  end
end
```

**View (index.html.erb)**:
```erb
<div class="permissions-grid">
  <% @professionals.each do |professional| %>
    <div class="permission-card">
      <h3><%= professional.full_name %></h3>
      
      <%= form_with model: professional, url: admin_professional_permission_path(professional), method: :patch do |f| %>
        <div class="permissions-list">
          <% Professional.system_permissions.each do |permission, _value| %>
            <div class="permission-item">
              <%= f.check_box "system_permissions", { multiple: true }, permission, nil %>
              <%= f.label "system_permissions_#{permission}", permission.humanize %>
            </div>
          <% end %>
        </div>
        
        <%= f.submit "Atualizar Permissões", class: "btn-primary" %>
      <% end %>
    </div>
  <% end %>
</div>
```

## 🔄 Fluxo de Permissões Proposto

### **Usuário com Permissão Completa**:
1. ✅ Acessa Workspace
2. ✅ Vê todos os documentos em andamento
3. ✅ Pode criar novos documentos
4. ✅ Pode atribuir responsáveis
5. ✅ Pode ver documentos liberados
6. ✅ Pode liberar documentos

### **Usuário com Permissão Limitada**:
1. ✅ Acessa Workspace
2. ❌ Vê apenas documentos onde é responsável
3. ❌ Não pode criar documentos
4. ❌ Não pode atribuir responsáveis
5. ❌ Não pode ver documentos liberados
6. ❌ Não pode liberar documentos

### **Usuário Apenas Visualização**:
1. ✅ Acessa Workspace
2. ❌ Vê apenas documentos onde tem permissão de visualização
3. ❌ Não pode criar documentos
4. ❌ Não pode atribuir responsáveis
5. ❌ Não pode ver documentos liberados

## 🧪 Testes Necessários

**RSpec Tests**:
```ruby
RSpec.describe Professional, type: :model do
  describe 'system permissions' do
    let(:professional) { create(:professional) }
    
    it 'can access documents when permission granted' do
      professional.system_permissions = ['can_access_documents']
      expect(professional.can_access_documents?).to be true
    end
    
    it 'cannot access documents when permission not granted' do
      professional.system_permissions = []
      expect(professional.can_access_documents?).to be false
    end
  end
end

RSpec.describe Admin::WorkspaceController, type: :controller do
  describe 'GET #index' do
    context 'when user cannot access documents' do
      before do
        current_user.professional.system_permissions = []
      end
      
      it 'redirects to dashboard' do
        get :index
        expect(response).to redirect_to(admin_dashboard_path)
      end
    end
  end
end
```

## 📝 Resumo das Alterações

### **Arquivos a Modificar**:
1. `app/models/professional.rb` - Adicionar permissões de sistema
2. `app/models/document_responsible.rb` - Corrigir relacionamento
3. `app/controllers/admin/workspace_controller.rb` - Adicionar verificações
4. `app/controllers/admin/released_documents_controller.rb` - Adicionar verificações
5. `app/controllers/admin/documents_controller.rb` - Adicionar verificações
6. `app/controllers/admin/document_responsibles_controller.rb` - Corrigir
7. `app/views/admin/workspace/index.html.erb` - Adicionar controles
8. `app/views/admin/released_documents/index.html.erb` - Adicionar controles
9. `app/views/layouts/admin.html.erb` - Atualizar navegação

### **Novos Arquivos**:
1. `db/migrate/xxx_add_system_permissions_to_professionals.rb`
2. `app/controllers/admin/professional_permissions_controller.rb`
3. `app/views/admin/professional_permissions/index.html.erb`

### **Benefícios**:
- ✅ Controle granular de permissões
- ✅ Separação clara entre áreas
- ✅ Correção do problema de responsáveis
- ✅ Interface intuitiva para gerenciamento
- ✅ Segurança robusta em todos os endpoints
- ✅ Flexibilidade para diferentes tipos de usuário

## 🚀 Status de Implementação

- [x] 1. Migration para system_permissions
- [x] 2. Atualizar modelo Professional
- [x] 3. Corrigir modelo DocumentResponsible
- [x] 4. Atualizar WorkspaceController
- [x] 5. Atualizar ReleasedDocumentsController
- [x] 6. Atualizar DocumentsController
- [x] 7. Corrigir DocumentResponsiblesController
- [x] 8. Atualizar views do Workspace
- [x] 9. Atualizar views de Released Documents
- [x] 10. Atualizar navegação (sidebar)
- [x] 11. Criar controller de ProfessionalPermissions
- [x] 12. Criar view de gerenciamento de permissões
- [x] 13. Adicionar rotas necessárias
- [ ] 14. Testes de funcionalidade
- [ ] 15. Testes de permissões

---

**Este documento serve como base para implementação sistemática do sistema de permissões avançado.**
