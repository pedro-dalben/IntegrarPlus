# Componentes de Tabela Reutilizáveis

## Visão Geral

Criamos um conjunto de componentes reutilizáveis para padronizar todas as tabelas do sistema, eliminando repetição de código e garantindo consistência visual.

## 🎯 **Problema Resolvido:**
- **Antes**: Cada tabela tinha código HTML repetitivo
- **Depois**: Componentes reutilizáveis com slots flexíveis

## Componentes Disponíveis

### 1. DataTableComponent
**Componente principal para tabelas**

```erb
<%= render Ui::DataTableComponent.new(collection: @resources) do |table| %>
  <%= table.with_headers do %>
    <!-- Cabeçalhos da tabela -->
  <% end %>

  <%= table.with_rows do %>
    <!-- Linhas da tabela -->
  <% end %>
<% end %>
```

### 2. TableHeaderComponent
**Para cabeçalhos de tabela**

```erb
<%= render Ui::TableHeaderComponent.new(text: "Nome da Coluna") %>
<%= render Ui::TableHeaderComponent.new(text: "Email", classes: "text-center") %>
```

### 3. TableRowComponent
**Para linhas de tabela**

```erb
<%= render Ui::TableRowComponent.new(model: resource) do |row| %>
  <%= row.with_cells do %>
    <!-- Células da linha -->
  <% end %>
<% end %>
```

### 4. TableCellComponent
**Para células de tabela**

```erb
<%= render Ui::TableCellComponent.new do %>
  Conteúdo da célula
<% end %>

<%= render Ui::TableCellComponent.new(classes: "text-center") do %>
  Célula centralizada
<% end %>
```

### 5. TableActionsComponent
**Para ações de tabela (ícones diretos)**

```erb
<!-- Automático no TableRowComponent -->
<!-- Ou manual: -->
<%= render Ui::TableActionsComponent.new(
  model: resource,
  resource_name: "professional"
) %>
```

## Exemplo Completo - Tabela de Grupos

```erb
<%= render Ui::DataTableComponent.new(collection: groups) do |table| %>
  <%= table.with_headers do %>
    <%= render Ui::TableHeaderComponent.new(text: "Nome") %>
    <%= render Ui::TableHeaderComponent.new(text: "Descrição") %>
    <%= render Ui::TableHeaderComponent.new(text: "Tipo") %>
    <%= render Ui::TableHeaderComponent.new(text: "Permissões") %>
    <%= render Ui::TableHeaderComponent.new(text: "Membros") %>
    <%= render Ui::TableHeaderComponent.new(text: "Última Atualização") %>
  <% end %>

  <%= table.with_rows do %>
    <% groups.each do |group| %>
      <%= render Ui::TableRowComponent.new(model: group) do |row| %>
        <%= row.with_cells do %>
          <%= render Ui::TableCellComponent.new do %>
            <div class="flex items-center">
              <div class="h-8 w-8 flex-shrink-0">
                <div class="h-8 w-8 rounded-full bg-brand-100 flex items-center justify-center dark:bg-brand-900">
                  <i class="bi bi-collection text-brand-600 dark:text-brand-400"></i>
                </div>
              </div>
              <div class="ml-4">
                <div class="text-sm font-medium text-gray-900 dark:text-white">
                  <%= link_to group.name, admin_group_path(group), class: "hover:text-brand-600 dark:hover:text-brand-400" %>
                </div>
              </div>
            </div>
          <% end %>

          <%= render Ui::TableCellComponent.new do %>
            <div class="text-sm text-gray-900 dark:text-white">
              <%= truncate(group.description, length: 50) if group.description.present? %>
            </div>
          <% end %>

          <%= render Ui::TableCellComponent.new do %>
            <% if group.admin? %>
              <span class="inline-flex items-center rounded-full bg-red-100 px-2.5 py-0.5 text-xs font-medium text-red-800 dark:bg-red-900 dark:text-red-200">
                <i class="bi bi-shield-check mr-1"></i>
                Administrador
              </span>
            <% else %>
              <span class="inline-flex items-center rounded-full bg-gray-100 px-2.5 py-0.5 text-xs font-medium text-gray-800 dark:bg-gray-700 dark:text-gray-200">
                <i class="bi bi-people mr-1"></i>
                Usuário
              </span>
            <% end %>
          <% end %>

          <%= render Ui::TableCellComponent.new do %>
            <div class="text-sm text-gray-900 dark:text-white">
              <%= group.permissions.count %> permissões
            </div>
          <% end %>

          <%= render Ui::TableCellComponent.new do %>
            <div class="text-sm text-gray-900 dark:text-white">
              <%= group.users.count %> membros
            </div>
          <% end %>

          <%= render Ui::TableCellComponent.new(classes: "text-sm text-gray-500 dark:text-gray-400") do %>
            <%= l(group.updated_at, format: :short) %>
          <% end %>
        <% end %>
      <% end %>
    <% end %>
  <% end %>
<% end %>
```

## Exemplo Simples - Tabela Básica

```erb
<%= render Ui::DataTableComponent.new(collection: @users) do |table| %>
  <%= table.with_headers do %>
    <%= render Ui::TableHeaderComponent.new(text: "Nome") %>
    <%= render Ui::TableHeaderComponent.new(text: "Email") %>
    <%= render Ui::TableHeaderComponent.new(text: "Status") %>
  <% end %>

  <%= table.with_rows do %>
    <% @users.each do |user| %>
      <%= render Ui::TableRowComponent.new(model: user) do |row| %>
        <%= row.with_cells do %>
          <%= render Ui::TableCellComponent.new do %>
            <%= user.full_name %>
          <% end %>

          <%= render Ui::TableCellComponent.new do %>
            <%= user.email %>
          <% end %>

          <%= render Ui::TableCellComponent.new do %>
            <span class="<%= user.active? ? 'text-green-600' : 'text-red-600' %>">
              <%= user.active? ? 'Ativo' : 'Inativo' %>
            </span>
          <% end %>
        <% end %>
      <% end %>
    <% end %>
  <% end %>
<% end %>
```

## Exemplo com Estado Vazio Customizado

```erb
<%= render Ui::DataTableComponent.new(collection: @items) do |table| %>
  <%= table.with_empty_state do %>
    <div class="text-center py-8">
      <i class="bi bi-box text-4xl text-gray-400 mb-4"></i>
      <p class="text-gray-500 dark:text-gray-400">Nenhum item encontrado</p>
      <%= link_to "Criar primeiro item", new_admin_item_path, 
          class: "mt-4 inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-brand-600 hover:bg-brand-700" %>
    </div>
  <% end %>

  <%= table.with_headers do %>
    <%= render Ui::TableHeaderComponent.new(text: "Nome") %>
    <%= render Ui::TableHeaderComponent.new(text: "Descrição") %>
  <% end %>

  <%= table.with_rows do %>
    <% @items.each do |item| %>
      <%= render Ui::TableRowComponent.new(model: item) do |row| %>
        <%= row.with_cells do %>
          <%= render Ui::TableCellComponent.new do %>
            <%= item.name %>
          <% end %>

          <%= render Ui::TableCellComponent.new do %>
            <%= item.description %>
          <% end %>
        <% end %>
      <% end %>
    <% end %>
  <% end %>
<% end %>
```

## Vantagens

1. **DRY (Don't Repeat Yourself)**: Elimina repetição de código HTML
2. **Consistência**: Todas as tabelas seguem o mesmo padrão visual
3. **Manutenibilidade**: Mudanças no padrão são feitas em um só lugar
4. **Flexibilidade**: Slots permitem customização quando necessário
5. **Reutilização**: Componentes podem ser usados em qualquer tabela
6. **Acessibilidade**: Estrutura HTML semântica consistente
7. **Responsividade**: Classes CSS padronizadas para mobile
8. **Ações Automáticas**: Ícones de ação incluídos automaticamente

## Como Migrar Tabelas Existentes

### 1. Identificar a Estrutura
```erb
<!-- Antes -->
<table class="w-full">
  <thead>
    <tr>
      <th>Nome</th>
      <th>Email</th>
    </tr>
  </thead>
  <tbody>
    <% @users.each do |user| %>
      <tr>
        <td><%= user.name %></td>
        <td><%= user.email %></td>
      </tr>
    <% end %>
  </tbody>
</table>
```

### 2. Converter para Componentes
```erb
<!-- Depois -->
<%= render Ui::DataTableComponent.new(collection: @users) do |table| %>
  <%= table.with_headers do %>
    <%= render Ui::TableHeaderComponent.new(text: "Nome") %>
    <%= render Ui::TableHeaderComponent.new(text: "Email") %>
  <% end %>

  <%= table.with_rows do %>
    <% @users.each do |user| %>
      <%= render Ui::TableRowComponent.new(model: user) do |row| %>
        <%= row.with_cells do %>
          <%= render Ui::TableCellComponent.new do %>
            <%= user.name %>
          <% end %>

          <%= render Ui::TableCellComponent.new do %>
            <%= user.email %>
          <% end %>
        <% end %>
      <% end %>
    <% end %>
  <% end %>
<% end %>
```

## Resultado

- ✅ **Código limpo** e organizado
- ✅ **Sem repetição** de HTML
- ✅ **Consistência visual** em todas as tabelas
- ✅ **Fácil manutenção** e evolução
- ✅ **Ações automáticas** com ícones diretos
- ✅ **Responsivo** e acessível
- ✅ **Flexível** para customizações
- ✅ **Padrão profissional** de interface

## Tabelas Migradas

- ✅ **Grupos**: Refatorada para usar componentes
- 🔄 **Profissionais**: Próxima a ser migrada
- 🔄 **Especialidades**: Próxima a ser migrada
- 🔄 **Especializações**: Próxima a ser migrada
- 🔄 **Tipos de Contrato**: Próxima a ser migrada
