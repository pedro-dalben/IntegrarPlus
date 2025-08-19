# 🔐 Sistema de Permissionamento - Tasks

## 📋 Visão Geral
Implementação de um sistema completo de permissionamento baseado em especialidades, com controle granular de ações (CRUD) e gerenciamento de convites de usuários.

## 🎯 Objetivos
- Relacionamento User ↔ Professional
- Permissões granulares por ação (index, show, new, create, edit, update, destroy)
- Sistema de convites com links simulados
- Controle de acesso dinâmico no menu
- Tela de gerenciamento de usuários com status de convites

## 📁 Estrutura de Arquivos

### Models
- `app/models/permission.rb` - Permissões dos usuários
- `app/models/invite.rb` - Convites de usuários
- `app/models/user_permission.rb` - Relacionamento User ↔ Permission
- Atualizar `app/models/user.rb` - Adicionar relacionamentos e métodos
- Atualizar `app/models/professional.rb` - Adicionar relacionamento com User

### Controllers
- `app/controllers/admin/users_controller.rb` - Gerenciamento de usuários
- `app/controllers/admin/invites_controller.rb` - Gerenciamento de convites
- `app/controllers/invites_controller.rb` - Aceitar convites
- Atualizar `app/controllers/admin/base_controller.rb` - Adicionar verificação de permissões
- Atualizar todos os controllers admin existentes

### Views
- `app/views/admin/users/` - Telas de gerenciamento de usuários
- `app/views/admin/invites/` - Telas de gerenciamento de convites
- `app/views/invites/` - Tela de aceitar convite
- Atualizar `app/views/admin/professionals/` - Adicionar link para usuário

### Policies
- `app/policies/user_policy.rb` - Políticas para usuários
- `app/policies/invite_policy.rb` - Políticas para convites
- Atualizar todas as policies existentes

### Navigation
- Atualizar `app/navigation/admin_nav.rb` - Adicionar itens de usuários e convites

### Migrations
- `db/migrate/xxx_add_user_to_professionals.rb`
- `db/migrate/xxx_create_permissions.rb`
- `db/migrate/xxx_create_invites.rb`
- `db/migrate/xxx_create_user_permissions.rb`

## 🚀 Tasks por Bloco

### Bloco 1: Estrutura de Dados ✅
- [x] Criar migration para adicionar user_id em professionals
- [x] Criar migration para tabela permissions
- [x] Criar migration para tabela invites
- [x] Criar migration para tabela user_permissions
- [x] Criar modelo Permission
- [x] Criar modelo Invite
- [x] Criar modelo UserPermission
- [x] Atualizar modelo User com relacionamentos
- [x] Atualizar modelo Professional com relacionamento User

### Bloco 2: Sistema de Permissões ✅
- [x] Implementar método `permit?` no modelo User
- [x] Criar sistema de permissões baseado em especialidades
- [x] Implementar verificação de permissões no BaseController
- [x] Atualizar todos os controllers admin com verificação de permissões
- [x] Criar UserPolicy
- [x] Criar InvitePolicy
- [x] Atualizar todas as policies existentes

### Bloco 3: Gerenciamento de Usuários ✅
- [x] Criar Admin::UsersController
- [x] Criar views para listagem de usuários
- [x] Implementar filtros por status (Ativo, Pendente, Inativo)
- [x] Implementar busca de usuários
- [x] Criar view de detalhes do usuário
- [x] Implementar edição de usuário
- [x] Implementar ativação/desativação de usuário

### Bloco 4: Sistema de Convites ✅
- [x] Criar Admin::InvitesController
- [x] Implementar geração de tokens únicos
- [x] Criar sistema de expiração de convites
- [x] Implementar contador de tentativas
- [x] Criar view para gerar convite
- [x] Implementar cópia de link para clipboard
- [x] Criar InvitesController para aceitar convites
- [x] Criar view de aceitar convite
- [x] Implementar validação de token

### Bloco 5: Navegação e Menu ✅
- [x] Atualizar AdminNav com itens de usuários
- [x] Implementar filtro de menu por permissões
- [x] Adicionar link para usuário na tela de profissionais
- [x] Implementar redirecionamento para usuários sem permissão

### Bloco 6: Integração e Testes ✅
- [x] Testar fluxo completo de criação de profissional
- [x] Testar sistema de permissões
- [x] Testar geração e aceitação de convites
- [x] Testar controle de acesso no menu
- [x] Testar redirecionamentos de segurança

### Bloco 7: Dados Iniciais ✅
- [x] Criar seeds para especialidades especiais (Admin, Programador, etc.)
- [x] Criar seeds para permissões padrão
- [x] Criar usuário administrador inicial
- [x] Configurar permissões por especialidade

## 🔧 Configurações Especiais

### Permissões por Especialidade
```ruby
PERMISSIONS_BY_SPECIALITY = {
  'Administrador' => ['*'], # Todas as permissões
  'TO' => ['dashboard.view', 'professionals.index', 'professionals.show', 'reports.view'],
  'Secretário' => ['dashboard.view', 'professionals.index', 'professionals.show', 'professionals.new', 'professionals.create'],
  'Gerente' => ['dashboard.view', 'professionals.*', 'users.index', 'users.show', 'users.edit', 'users.update'],
  'Programador' => ['dashboard.view', 'settings.*', 'users.*']
}
```

### Configurações de Convite
- Expiração: 7 dias
- Tentativas máximas: 5
- Token: 32 caracteres aleatórios

## 🎨 Interface

### Tela de Usuários
- Lista com status visual (✅⏳❌)
- Filtros por status
- Busca por nome/email
- Ações contextuais por status

### Tela de Convites
- Geração de link com cópia
- Visualização de convites pendentes
- Reenvio de convites expirados

## 🔒 Segurança
- Verificação de permissões em todas as ações
- Tokens únicos e seguros
- Expiração automática de convites
- Log de tentativas de acesso
- Redirecionamento para usuários sem permissão

## 📝 Notas Importantes
- Manter compatibilidade com sistema existente
- Implementar gradualmente para não quebrar funcionalidades
- Testar cada bloco antes de prosseguir
- Documentar mudanças no código
- Commitar cada bloco separadamente
