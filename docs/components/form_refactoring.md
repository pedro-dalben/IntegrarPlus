# Refatoração de Formulários - Uso de Partials

## Problema Identificado

Os formulários de criação e edição de profissionais estavam duplicados em dois arquivos separados:
- `app/views/admin/professionals/new.html.erb`
- `app/views/admin/professionals/edit.html.erb`

Isso violava o princípio **DRY (Don't Repeat Yourself)** e tornava a manutenção mais difícil.

## Solução Implementada

### 1. Criação do Partial `_form.html.erb`

Criamos um partial reutilizável que contém todo o formulário:

```erb
<!-- app/views/admin/professionals/_form.html.erb -->
<%= form_with model: [:admin, professional], local: true do |form| %>
  <!-- Todo o conteúdo do formulário aqui -->
<% end %>
```

### 2. Refatoração dos Arquivos Principais

#### `new.html.erb` (Antes)
```erb
<%= render ::Layouts::AdminComponent.new do |c| %>
  <% c.with_actions do %>
    <!-- Botão voltar -->
  <% end %>

  <div class="space-y-6">
    <%= form_with model: [:admin, @professional], local: true do |form| %>
      <!-- 200+ linhas de código duplicado -->
    <% end %>
  </div>
<% end %>
```

#### `new.html.erb` (Depois)
```erb
<%= render ::Layouts::AdminComponent.new do |c| %>
  <% c.with_actions do %>
    <!-- Botão voltar -->
  <% end %>

  <div class="space-y-6">
    <%= render 'form', professional: @professional %>
  </div>
<% end %>
```

#### `edit.html.erb` (Antes)
```erb
<%= render ::Layouts::AdminComponent.new do |c| %>
  <% c.with_actions do %>
    <!-- Botão voltar -->
  <% end %>

  <div class="space-y-6">
    <%= form_with model: [:admin, @professional], local: true do |form| %>
      <!-- 200+ linhas de código duplicado -->
    <% end %>
  </div>
<% end %>
```

#### `edit.html.erb` (Depois)
```erb
<%= render ::Layouts::AdminComponent.new do |c| %>
  <% c.with_actions do %>
    <!-- Botão voltar -->
  <% end %>

  <div class="space-y-6">
    <%= render 'form', professional: @professional %>
  </div>
<% end %>
```

## Benefícios da Refatoração

### ✅ **Manutenibilidade**
- **Um único local** para alterar o formulário
- **Sem duplicação** de código
- **Fácil atualização** de campos e validações

### ✅ **Consistência**
- **Mesmo comportamento** em criação e edição
- **Mesmos estilos** e validações
- **Mesma estrutura** de campos

### ✅ **Reutilização**
- **Partial pode ser usado** em outros contextos
- **Fácil de testar** isoladamente
- **Componentização** do formulário

### ✅ **Legibilidade**
- **Arquivos principais** mais limpos e focados
- **Separação clara** de responsabilidades
- **Código mais organizado**

## Estrutura Final

```
app/views/admin/professionals/
├── _form.html.erb          # Partial com o formulário
├── new.html.erb            # Página de criação (usa partial)
├── edit.html.erb           # Página de edição (usa partial)
└── index.html.erb          # Lista de profissionais
```

## Como Funciona

### 1. **Partial `_form.html.erb`**
- Recebe a variável `professional` como parâmetro
- Contém todo o formulário com campos e validações
- Usa `professional.new_record?` para determinar se é criação ou edição

### 2. **Arquivos Principais**
- `new.html.erb`: Renderiza o partial com `@professional` (novo)
- `edit.html.erb`: Renderiza o partial com `@professional` (existente)

### 3. **Renderização**
```erb
<%= render 'form', professional: @professional %>
```

## Exemplos de Uso

### Renderização Simples
```erb
<%= render 'form', professional: @professional %>
```

### Renderização com Variáveis Locais
```erb
<%= render 'form', 
    professional: @professional,
    contract_types: @contract_types,
    groups: @groups %>
```

### Renderização Condicional
```erb
<% if @professional.persisted? %>
  <%= render 'form', professional: @professional %>
<% else %>
  <%= render 'form', professional: Professional.new %>
<% end %>
```

## Manutenção

### Para Alterar Campos
1. **Edite apenas** `_form.html.erb`
2. **Alterações aplicam** automaticamente em criação e edição
3. **Sem risco** de esquecer um arquivo

### Para Adicionar Novos Campos
1. **Adicione no partial** `_form.html.erb`
2. **Verifique se** as variáveis estão disponíveis nos controllers
3. **Teste** criação e edição

### Para Alterar Validações
1. **Modifique o partial** `_form.html.erb`
2. **Atualize o modelo** se necessário
3. **Teste** ambos os fluxos

## Padrão para Outros Formulários

### Estrutura Recomendada
```
app/views/admin/[resource]/
├── _form.html.erb          # Partial do formulário
├── new.html.erb            # Página de criação
├── edit.html.erb           # Página de edição
└── index.html.erb          # Lista
```

### Nomenclatura
- **Partial**: `_form.html.erb`
- **Variável**: `[resource]` (ex: `professional`, `user`, `product`)
- **Renderização**: `<%= render 'form', [resource]: @[resource] %>`

## Conclusão

A refatoração para usar partials resolve:
- ✅ **Duplicação de código**
- ✅ **Dificuldade de manutenção**
- ✅ **Inconsistências entre formulários**
- ✅ **Complexidade desnecessária**

**Resultado**: Código mais limpo, manutenível e consistente, seguindo as melhores práticas do Rails.
