# Correção do Sistema de Permissionamento - Anamnese e Beneficiários

## 📋 Resumo das Alterações

Este documento detalha as correções implementadas no sistema de permissionamento para as telas de **Anamnese** e **Beneficiários**.

## 🔧 Problemas Identificados

### Antes da Correção
- Os controllers de `AnamnesesController` e `BeneficiariesController` não estavam verificando explicitamente as permissões via Pundit
- Faltavam permissões específicas para actions como `new`, `search`, `today`, `by_professional`
- As policies não tinham métodos específicos para todas as actions

### Após a Correção
✅ Todos os métodos dos controllers agora verificam permissões via `authorize`
✅ Novas permissões foram adicionadas ao sistema
✅ As policies foram atualizadas para verificar cada action específica
✅ Os seeds foram atualizados para incluir as novas permissões nos grupos

## 🛠️ Alterações Implementadas

### 1. Controllers Atualizados

#### `app/controllers/admin/anamneses_controller.rb`
```ruby
def index
  authorize Anamnesis, policy_class: Admin::AnamnesisPolicy
end

def today
  authorize Anamnesis, policy_class: Admin::AnamnesisPolicy
end

def by_professional
  authorize Anamnesis, policy_class: Admin::AnamnesisPolicy
end
```

#### `app/controllers/admin/beneficiaries_controller.rb`
```ruby
def index
  authorize Beneficiary, policy_class: Admin::BeneficiaryPolicy
end

def search
  authorize Beneficiary, policy_class: Admin::BeneficiaryPolicy
end
```

### 2. Policies Atualizadas

#### `app/policies/admin/anamnesis_policy.rb`
Adicionados métodos:
- `new?` - Verifica `anamneses.new`
- `edit?` - Verifica `anamneses.edit`
- `today?` - Verifica `anamneses.today`
- `by_professional?` - Verifica `anamneses.by_professional`

#### `app/policies/admin/beneficiary_policy.rb`
Adicionados métodos:
- `new?` - Verifica `beneficiaries.new`
- `edit?` - Verifica `beneficiaries.edit`
- `search?` - Verifica `beneficiaries.search`

### 3. Novas Permissões Cadastradas

#### Beneficiários
- `beneficiaries.index` - Listar beneficiários
- `beneficiaries.show` - Ver detalhes do beneficiário
- `beneficiaries.new` - Criar novo beneficiário (formulário)
- `beneficiaries.create` - Criar novos beneficiários
- `beneficiaries.edit` - Editar beneficiários
- `beneficiaries.update` - Atualizar beneficiários
- `beneficiaries.destroy` - Excluir beneficiários
- `beneficiaries.search` - Buscar beneficiários

#### Anamneses
- `anamneses.index` - Listar anamneses
- `anamneses.show` - Ver detalhes da anamnese
- `anamneses.new` - Criar nova anamnese (formulário)
- `anamneses.create` - Criar anamnese
- `anamneses.edit` - Editar anamnese
- `anamneses.update` - Atualizar anamnese
- `anamneses.complete` - Concluir anamnese
- `anamneses.view_all` - Ver todas as anamneses (não apenas próprias)
- `anamneses.today` - Ver anamneses de hoje
- `anamneses.by_professional` - Ver anamneses por profissional

### 4. Grupos Atualizados

#### Grupo "Profissionais"
Permissões básicas incluindo:
- Visualizar beneficiários e anamneses
- Criar e editar suas próprias anamneses
- Buscar beneficiários

#### Grupo "Recepção"
Permissões amplas incluindo:
- Criar e editar beneficiários
- Ver todas as anamneses (`anamneses.view_all`)
- Agendar e gerenciar anamneses

#### Grupo "Clínico"
Permissões clínicas incluindo:
- Criar e editar beneficiários
- Ver e gerenciar todas as anamneses
- Completar anamneses

#### Grupo "Admin"
Acesso total a todas as funcionalidades

## 📝 Como Funciona o Sistema

### Verificação Automática no BaseController
O `Admin::BaseController` tem um `before_action :check_permissions` que verifica automaticamente:

```ruby
def check_permissions
  action_permission = "#{controller_name}.#{action_name}"

  return if controller_name == 'dashboard' && action_name == 'index'
  return if current_user.permit?(action_permission)

  redirect_to admin_root_path, alert: 'Você não tem permissão para acessar esta área.'
end
```

### Verificação Explícita via Pundit
Além da verificação automática, cada controller também usa `authorize` explicitamente:

```ruby
authorize Anamnesis, policy_class: Admin::AnamnesisPolicy
```

### Fluxo de Verificação
1. **BaseController** verifica automaticamente via `check_permissions`
2. **Controller** verifica explicitamente via `authorize`
3. **Policy** verifica se o usuário tem a permissão específica
4. **Professional/User** verifica via grupos se tem a permissão

## 🚀 Como Usar

### Atribuir Usuário a um Grupo

1. Acesse `/admin/professionals`
2. Edite o profissional
3. Selecione os grupos desejados
4. Salve

### Configurar Permissões de um Grupo

1. Acesse `/admin/groups`
2. Edite o grupo desejado
3. Marque/desmarque as permissões
4. Salve

### Verificar Permissões no Console

```ruby
user = User.find_by(email: 'usuario@exemplo.com')

user.permit?('anamneses.index')
user.permit?('beneficiaries.create')

user.groups.pluck(:name)

user.professional.groups.map(&:name)
```

### Executar Seeds para Atualizar Permissões

```bash
rails runner "load 'db/seeds/permissionamento_setup.rb'"
```

## 🔒 Regras de Segurança

### Anamneses
- Profissionais só podem ver suas próprias anamneses, exceto se tiverem `anamneses.view_all`
- Apenas anamneses não concluídas podem ser editadas
- A conclusão requer permissão específica `anamneses.complete`

### Beneficiários
- Todos os usuários com permissão `beneficiaries.index` podem ver todos os beneficiários
- Criação e edição requerem permissões separadas
- Busca é uma permissão específica para APIs e autocomplete

## ⚠️ Importante

1. **Grupos Admin** têm acesso total automaticamente
2. **Dashboard** é acessível para todos os usuários autenticados
3. **Permissões são cumulativas** - um usuário em múltiplos grupos tem todas as permissões combinadas
4. **Sempre execute os seeds** após adicionar novas permissões

## 🧪 Testando o Sistema

### Teste 1: Acesso Negado
1. Crie um usuário sem grupo
2. Tente acessar `/admin/anamneses`
3. Deve ser redirecionado com mensagem de erro

### Teste 2: Acesso Permitido
1. Adicione o usuário ao grupo "Profissionais"
2. Tente acessar `/admin/anamneses`
3. Deve conseguir acessar a listagem

### Teste 3: Permissões Granulares
1. Remova a permissão `anamneses.create` do grupo
2. O usuário deve ver a lista mas não conseguir criar novas anamneses
3. O botão "Nova Anamnese" não deve aparecer

## 📊 Resumo de Permissões por Grupo

| Permissão | Admin | Clínico | Recepção | Profissionais |
|-----------|-------|---------|----------|---------------|
| beneficiaries.index | ✅ | ✅ | ✅ | ✅ |
| beneficiaries.show | ✅ | ✅ | ✅ | ✅ |
| beneficiaries.new | ✅ | ✅ | ✅ | ❌ |
| beneficiaries.create | ✅ | ✅ | ✅ | ❌ |
| beneficiaries.edit | ✅ | ✅ | ✅ | ❌ |
| beneficiaries.update | ✅ | ✅ | ✅ | ❌ |
| beneficiaries.search | ✅ | ✅ | ✅ | ✅ |
| anamneses.index | ✅ | ✅ | ✅ | ✅ |
| anamneses.show | ✅ | ✅ | ✅ | ✅ |
| anamneses.new | ✅ | ✅ | ✅ | ✅ |
| anamneses.create | ✅ | ✅ | ✅ | ✅ |
| anamneses.edit | ✅ | ✅ | ✅ | ✅ |
| anamneses.update | ✅ | ✅ | ✅ | ✅ |
| anamneses.complete | ✅ | ✅ | ❌ | ✅ |
| anamneses.view_all | ✅ | ✅ | ✅ | ❌ |

## 🔗 Documentos Relacionados

- [Sistema de Permissões](SISTEMA_PERMISSOES.md)
- [Projeto Regras](../PROJECT_RULES.md)
- [Sistema Anamnese Pacientes](tasks/sistema_anamnese_pacientes.md)

---

**Data da Correção**: 21/10/2025
**Versão**: 1.0



