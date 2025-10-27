# Sistema de Permissões - IntegrarPlus

## Visão Geral

O IntegrarPlus possui um sistema completo de permissões baseado em grupos. Cada usuário pertence a um ou mais grupos, e cada grupo possui permissões específicas.

**Total de Permissões Cadastradas: 100**

## Como Funciona

### 1. Estrutura

```
User → Professional → Group → Permission
```

- **User**: Usuário do sistema (autenticação)
- **Professional**: Profissional vinculado ao usuário
- **Group**: Grupo que define conjunto de permissões
- **Permission**: Permissão individual por funcionalidade

### 2. Validação Automática

O `Admin::BaseController` implementa validação automática:

```ruby
before_action :check_permissions

def check_permissions
  action_permission = "#{controller_name}.#{action_name}"
  return if current_user.permit?(action_permission)
  redirect_to admin_root_path, alert: 'Sem permissão'
end
```

### 3. Menu Dinâmico

O menu lateral (`Ui::SidebarComponent`) exibe apenas opções que o usuário tem permissão:

```ruby
def user_can_access?(permission_key)
  return true if current_user.admin?
  current_user.permit?(permission_key)
end
```

## Permissões por Módulo

### Dashboard (1 permissão)
- `dashboard.view` - Visualizar dashboard

### Profissionais (7 permissões)
- `professionals.index` - Listar profissionais
- `professionals.show` - Ver detalhes
- `professionals.new` - Formulário novo
- `professionals.create` - Salvar
- `professionals.edit` - Formulário edição
- `professionals.update` - Atualizar
- `professionals.destroy` - Excluir

### Grupos (1 permissão)
- `groups.manage` - Gerenciar grupos (CRUD completo)

### Especialidades (2 permissões)
- `specialities.index` - Listar
- `specialities.manage` - Gerenciar (CRUD)

### Especializações (2 permissões)
- `specializations.index` - Listar
- `specializations.manage` - Gerenciar (CRUD)

### Tipos de Contrato (2 permissões)
- `contract_types.index` - Listar
- `contract_types.manage` - Gerenciar (CRUD)

### Usuários (9 permissões)
- `users.index` - Listar usuários
- `users.show` - Ver detalhes
- `users.new` - Formulário novo
- `users.create` - Salvar
- `users.edit` - Formulário edição
- `users.update` - Atualizar
- `users.destroy` - Excluir
- `users.activate` - Ativar
- `users.deactivate` - Desativar

### Convites (7 permissões)
- `invites.index` - Listar convites
- `invites.show` - Ver detalhes
- `invites.create` - Criar
- `invites.update` - Atualizar
- `invites.destroy` - Excluir
- `invites.resend` - Reenviar

### Beneficiários (8 permissões)
- `beneficiaries.index` - Listar
- `beneficiaries.show` - Ver detalhes
- `beneficiaries.new` - Formulário novo
- `beneficiaries.create` - Criar
- `beneficiaries.edit` - Formulário edição
- `beneficiaries.update` - Atualizar
- `beneficiaries.destroy` - Excluir
- `beneficiaries.search` - Buscar

### Anamneses (10 permissões)
- `anamneses.index` - Listar anamneses
- `anamneses.show` - Ver detalhes
- `anamneses.new` - Formulário novo
- `anamneses.create` - Criar
- `anamneses.edit` - Formulário edição
- `anamneses.update` - Atualizar
- `anamneses.complete` - Concluir
- `anamneses.today` - Ver anamneses de hoje
- `anamneses.by_professional` - Ver por profissional
- `anamneses.view_all` - Ver todas (não apenas próprias)

### Agendas (7 permissões)
- `agendas.read` - Visualizar agendas
- `agendas.create` - Criar
- `agendas.update` - Editar
- `agendas.destroy` - Excluir
- `agendas.activate` - Ativar
- `agendas.archive` - Arquivar
- `agendas.duplicate` - Duplicar

### Portal de Operadoras (4 permissões)
- `portal_intakes.index` - Listar entradas
- `portal_intakes.show` - Ver detalhes
- `portal_intakes.update` - Atualizar
- `portal_intakes.schedule_anamnesis` - Agendar anamnese

### Operadoras (7 permissões)
- `external_users.index` - Listar
- `external_users.show` - Ver detalhes
- `external_users.new` - Formulário novo
- `external_users.create` - Salvar
- `external_users.edit` - Formulário edição
- `external_users.update` - Atualizar
- `external_users.destroy` - Excluir

### Documentos (6 permissões)
- `documents.access` - Acessar área
- `documents.create` - Criar novos
- `documents.view_released` - Ver liberados
- `documents.manage_permissions` - Gerenciar permissões
- `documents.assign_responsibles` - Atribuir responsáveis
- `documents.release` - Liberar

### Fluxogramas (11 permissões)
- `flow_charts.index` - Listar
- `flow_charts.show` - Ver detalhes
- `flow_charts.new` - Formulário novo
- `flow_charts.create` - Criar
- `flow_charts.edit` - Formulário edição
- `flow_charts.update` - Atualizar
- `flow_charts.destroy` - Excluir
- `flow_charts.publish` - Publicar
- `flow_charts.duplicate` - Duplicar
- `flow_charts.export_pdf` - Exportar PDF
- `flow_charts.manage` - Gerenciar (permissão global)

### Organogramas (9 permissões)
- `organograms.index` - Listar
- `organograms.show` - Visualizar
- `organograms.create` - Criar
- `organograms.update` - Editar
- `organograms.destroy` - Excluir
- `organograms.editor` - Usar editor
- `organograms.publish` - Publicar
- `organograms.export` - Exportar
- `organograms.import` - Importar dados

### Escolas (4 permissões)
- `schools.view` - Visualizar
- `schools.create` - Criar
- `schools.edit` - Editar
- `schools.destroy` - Excluir

### Configurações (2 permissões)
- `settings.read` - Ler configurações
- `settings.write` - Editar configurações

### Relatórios (2 permissões)
- `reports.view` - Visualizar relatórios
- `reports.generate` - Gerar relatórios

## Grupos Especiais

### Grupo Admin
- Flag `is_admin = true`
- Bypass de todas as permissões
- Acesso total ao sistema

## Como Adicionar Novas Permissões

### 1. Criar Permissão no Console

```ruby
Permission.create!(
  key: 'modulo.acao',
  description: 'Descrição da permissão'
)
```

### 2. Adicionar ao Grupo

```ruby
group = Group.find_by(name: 'Nome do Grupo')
group.add_permission('modulo.acao')
```

### 3. Atualizar Menu (se aplicável)

Editar `app/components/ui/sidebar_component.rb` e adicionar item com `permission:`:

```ruby
{
  title: 'Nova Funcionalidade',
  path: '/admin/nova_funcionalidade',
  icon: icon_method,
  active: current_path&.start_with?('/admin/nova_funcionalidade'),
  permission: 'modulo.acao'
}
```

### 4. Controller Valida Automaticamente

O `BaseController` já valida automaticamente usando:
- Nome do controller
- Nome da action

Exemplo: `professionals#index` → verifica `professionals.index`

## Testes de Permissões

### Verificar se Usuário Tem Permissão

```ruby
# No controller
current_user.permit?('professionals.index')

# No model
professional.groups.any? { |g| g.has_permission?('professionals.index') }

# Admin bypass
professional.admin? # true se pertence a grupo admin
```

### Verificar Permissões do Menu

```ruby
# No component
user_can_access?('professionals.index')
user_can_access_any?(['users.index', 'groups.manage'])
```

## Segurança

### Validações Implementadas

1. **Controller Level**: Validação automática em todas as actions
2. **View Level**: Menu mostra apenas opções permitidas
3. **Model Level**: Métodos `permit?` e `admin?` para verificações
4. **Redirect**: Redirecionamento seguro para dashboard sem permissão

### Bypass de Segurança

⚠️ **ATENÇÃO**: Apenas grupos com `is_admin = true` fazem bypass

```ruby
def check_permissions
  return if current_user.admin? # BYPASS TOTAL
  # ... validações normais
end
```

## Debugging

### Ver Permissões de um Usuário

```ruby
user = User.find(1)
permissions = user.professional.groups.flat_map(&:permissions).uniq
permissions.each { |p| puts "#{p.key} - #{p.description}" }
```

### Ver Grupos de um Usuário

```ruby
user = User.find(1)
user.professional.groups.each do |g|
  puts "#{g.name} (Admin: #{g.admin?})"
  puts "Permissões: #{g.permissions.count}"
end
```

### Testar Permissão Específica

```ruby
user = User.find(1)
puts user.permit?('professionals.index') # true/false
```

## Migrações Futuras Sugeridas

1. **Cache de Permissões**: Cachear permissões do usuário para performance
2. **Auditoria**: Log de tentativas de acesso negadas
3. **Permissões Temporárias**: Sistema de permissões com data de validade
4. **Hierarquia de Permissões**: Permissão pai concede permissões filhas automaticamente
5. **API de Permissões**: Endpoint para apps externos verificarem permissões

## Compatibilidade

- ✅ Rails 8.0.3
- ✅ ViewComponent
- ✅ Stimulus
- ✅ MeiliSearch (para busca de grupos/permissões)

## Manutenção

Para manter o sistema atualizado:

1. Sempre criar permissão ao adicionar novo controller/action
2. Atualizar menu quando adicionar nova funcionalidade
3. Documentar novas permissões neste arquivo
4. Testar permissões após cada deploy
5. Revisar grupos periodicamente

---

**Última Atualização**: 27/10/2025
**Versão**: 1.0
