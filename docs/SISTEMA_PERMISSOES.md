# 🔐 Sistema de Permissionamento - Guia Completo

## 📋 Visão Geral

O sistema de permissionamento do IntegrarPlus funciona através de **Grupos** e **Permissões**, permitindo controle granular de acesso às funcionalidades do sistema.

## 🏗️ Arquitetura

### Estrutura de Dados
```
User (Usuário)
├── belongs_to Professional
└── has_many Groups (através de Memberships)

Group (Grupo)
├── has_many Users (através de Memberships)
├── has_many Permissions (através de GroupPermissions)
└── is_admin (boolean)

Permission (Permissão)
├── key (string) - Ex: 'professionals.index'
└── description (string) - Ex: 'Listar profissionais'
```

### Fluxo de Verificação
1. **User** → **Groups** → **Permissions** → **Access Control**
2. Método `user.permit?('permission.key')` verifica se o usuário tem a permissão
3. Controllers verificam permissões antes de permitir acesso

## 🎯 Como Configurar Permissões

### 1. **Tela de Grupos** (Principal)
Acesse `/admin/groups` para gerenciar grupos e suas permissões:

#### Criar Novo Grupo
1. Clique em "Novo Grupo"
2. Preencha:
   - **Nome**: Ex: "Médicos", "Secretárias", "Administradores"
   - **Descrição**: Descrição do propósito do grupo
   - **Grupo Administrador**: Marque se deve ter acesso total
3. **Selecione as Permissões**:
   - Dashboard → `dashboard.view`
   - Profissionais → `professionals.index`, `professionals.show`, etc.
   - Usuários → `users.index`, `users.show`, etc.
   - Configurações → `settings.read`, `settings.write`
   - Relatórios → `reports.view`, `reports.generate`

#### Editar Grupo Existente
1. Clique no grupo na lista
2. Clique em "Editar"
3. Modifique permissões conforme necessário

### 2. **Exemplos de Configuração**

#### Grupo "Médicos"
```ruby
Permissões:
- dashboard.view
- professionals.index
- professionals.show
- professionals.edit
- professionals.update
- reports.view
```

#### Grupo "Secretárias"
```ruby
Permissões:
- dashboard.view
- professionals.index
- professionals.show
- professionals.new
- professionals.create
- professionals.edit
- professionals.update
```

#### Grupo "Recepção"
```ruby
Permissões:
- dashboard.view
- professionals.index
- professionals.show
```

### 3. **Permissões Disponíveis**

#### Dashboard
- `dashboard.view` - Visualizar dashboard

#### Profissionais
- `professionals.index` - Listar profissionais
- `professionals.show` - Ver detalhes de profissional
- `professionals.new` - Criar novo profissional
- `professionals.create` - Salvar profissional
- `professionals.edit` - Editar profissional
- `professionals.update` - Atualizar profissional
- `professionals.destroy` - Excluir profissional

#### Usuários
- `users.index` - Listar usuários
- `users.show` - Ver detalhes de usuário
- `users.new` - Criar novo usuário
- `users.create` - Salvar usuário
- `users.edit` - Editar usuário
- `users.update` - Atualizar usuário
- `users.destroy` - Excluir usuário
- `users.activate` - Ativar usuário
- `users.deactivate` - Desativar usuário

#### Convites
- `invites.index` - Listar convites
- `invites.show` - Ver detalhes de convite
- `invites.create` - Criar convite
- `invites.update` - Atualizar convite
- `invites.destroy` - Excluir convite
- `invites.resend` - Reenviar convite

#### Grupos
- `groups.manage` - Gerenciar grupos

#### Configurações
- `settings.read` - Ler configurações
- `settings.write` - Editar configurações

#### Relatórios
- `reports.view` - Visualizar relatórios
- `reports.generate` - Gerar relatórios

## 🔧 Como Funciona na Prática

### 1. **Menu Dinâmico**
O menu lateral é filtrado automaticamente baseado nas permissões do usuário:
```ruby
# app/navigation/admin_nav.rb
def items
  [
    { label: 'Dashboard', path: '/admin', required_permission: 'dashboard.view' },
    { label: 'Profissionais', path: '/admin/professionals', required_permission: 'professionals.read' }
  ]
end
```

### 2. **Controle de Acesso nos Controllers**
```ruby
# app/controllers/admin/base_controller.rb
def check_permissions
  action_permission = "#{controller_name}.#{action_name}"
  
  unless current_user.permit?(action_permission)
    redirect_to admin_path, alert: 'Você não tem permissão para acessar esta área.'
  end
end
```

### 3. **Verificação em Views**
```erb
<% if current_user.permit?('professionals.create') %>
  <%= link_to 'Novo Profissional', new_admin_professional_path %>
<% end %>
```

## 📝 Exemplos de Uso

### Cenário 1: Médico
**Grupo**: Médicos
**Permissões**: Ver e editar profissionais, visualizar relatórios
**Acesso**: Dashboard, Lista de Profissionais, Relatórios

### Cenário 2: Secretária
**Grupo**: Secretárias  
**Permissões**: Criar, editar e visualizar profissionais
**Acesso**: Dashboard, Gerenciamento completo de Profissionais

### Cenário 3: Recepção
**Grupo**: Recepção
**Permissões**: Apenas visualizar profissionais
**Acesso**: Dashboard, Lista de Profissionais (somente leitura)

## 🚀 Comandos Úteis

### Executar Seeds
```bash
rails db:seed
```

### Verificar Permissões no Console
```ruby
# Rails console
user = User.first
user.permit?('professionals.index')  # => true/false
user.groups.pluck(:name)             # => ["Médicos", "Secretárias"]
```

### Criar Grupo via Console
```ruby
group = Group.create!(
  name: 'Novo Grupo',
  description: 'Descrição do grupo'
)

# Adicionar permissões
group.add_permission('dashboard.view')
group.add_permission('professionals.index')
```

## 🔒 Segurança

### Boas Práticas
1. **Princípio do Menor Privilégio**: Dê apenas as permissões necessárias
2. **Revisão Regular**: Revise permissões periodicamente
3. **Logs de Acesso**: Monitore tentativas de acesso negado
4. **Testes**: Teste permissões com diferentes usuários

### Verificações Automáticas
- Controllers verificam permissões automaticamente
- Menu é filtrado dinamicamente
- Redirecionamento para usuários sem permissão
- Logs de tentativas de acesso

## 📊 Monitoramento

### Verificar Status
```ruby
# Total de grupos
Group.count

# Total de permissões
Permission.count

# Usuários por grupo
Group.joins(:professionals).group(:name).count

# Permissões por grupo
Group.joins(:permissions).group(:name).count
```

### Logs de Acesso
O sistema registra automaticamente:
- Tentativas de acesso negado
- Mudanças de permissões
- Criação/exclusão de grupos

## 🎯 Próximos Passos

1. **Testar o Sistema**: Crie usuários de teste com diferentes grupos
2. **Configurar Grupos**: Defina grupos específicos para sua organização
3. **Ajustar Permissões**: Refine permissões conforme necessário
4. **Documentar**: Mantenha documentação atualizada das configurações

---

**💡 Dica**: Comece com poucas permissões e adicione conforme necessário. É mais fácil adicionar permissões do que remover depois!
