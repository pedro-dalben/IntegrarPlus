# Componentes de Formulário Reutilizáveis

## Visão Geral

Criamos um conjunto de componentes reutilizáveis para padronizar todas as telas de formulário (new/edit) e visualização (show) do sistema, seguindo exatamente o padrão dos profissionais.

## 🎯 **Melhorias de UX Implementadas**

### **Antes vs. Depois: Botões de Ação**

#### ❌ **Antes: Dropdown (3 pontos)**
- Botão com 3 pontos (⋯) 
- Menu suspenso que precisa ser aberto
- 2 cliques para executar ação (abrir + selecionar)
- Menos intuitivo e mais lento
- Pior experiência mobile

#### ✅ **Depois: Ícones Diretos**
- 👁️ **Ver**: Ícone de olho (azul)
- ✏️ **Editar**: Ícone de lápis (cinza)  
- 🗑️ **Excluir**: Ícone de lixeira (vermelho)
- **1 clique direto** para executar ação
- **Mais intuitivo** e rápido
- **Melhor para mobile** (área de toque maior)
- **Padrão moderno** de UX

### **Cores Padronizadas**
- **Ver**: `text-brand-600` (azul)
- **Editar**: `text-gray-600` (cinza)
- **Excluir**: `text-red-600` (vermelho)
- **Hover**: Cores mais escuras para feedback visual

## Componentes Disponíveis

### 1. FormPageComponent
**Para páginas de formulário (new/edit)**

```erb
<%= render Ui::FormPageComponent.new(
  model: @resource,
  back_path: admin_resources_path,
  title: "Título da Página",
  subtitle: "Subtítulo opcional"
) do |page| %>
  
  <%= form_with model: [:admin, @resource], local: true do |form| %>
    <%= page.with_sections do %>
      <!-- Seções do formulário -->
    <% end %>

    <%= page.with_form_actions do %>
      <!-- Ações do formulário -->
    <% end %>
  <% end %>
<% end %>
```

### 2. FormSectionComponent
**Para seções de formulário**

```erb
<%= render Ui::FormSectionComponent.new(
  title: "Nome da Seção",
  subtitle: "Descrição opcional"
) do |section| %>
  <%= section.with_fields do %>
    <!-- Campos do formulário -->
  <% end %>
<% end %>
```

### 3. FormActionsComponent
**Para ações do formulário**

```erb
<%= render Ui::FormActionsComponent.new(
  cancel_path: admin_resources_path,
  submit_text: "Texto do Botão"
) %>
```

### 4. ShowPageComponent
**Para páginas de visualização (show)**

```erb
<%= render Ui::ShowPageComponent.new(
  model: @resource,
  back_path: admin_resources_path,
  title: "Título da Página",
  subtitle: "Subtítulo opcional"
) do |page| %>
  
  <%= page.with_sections do %>
    <!-- Seções de visualização -->
  <% end %>

  <%= page.with_page_actions(edit_path: edit_admin_resource_path(@resource)) %>
<% end %>
```

### 5. ShowSectionComponent
**Para seções de visualização**

```erb
<%= render Ui::ShowSectionComponent.new(
  title: "Nome da Seção",
  subtitle: "Descrição opcional"
) do |section| %>
  <%= section.with_fields do %>
    <!-- Campos de visualização -->
  <% end %>
<% end %>
```

### 6. PageActionsComponent
**Para ações da página**

```erb
<%= render Ui::PageActionsComponent.new(
  back_path: admin_resources_path,
  edit_path: edit_admin_resource_path(@resource)
) %>
```

### 7. TableActionsComponent 🆕
**Para ações de tabela com ícones diretos**

```erb
<%= render Ui::TableActionsComponent.new(
  model: resource,
  resource_name: "professional"
) %>
```

## Exemplo Completo - Tela New

```erb
<%= render Ui::FormPageComponent.new(
  model: @professional,
  back_path: admin_professionals_path,
  title: "Novo Profissional",
  subtitle: "Cadastre um novo profissional"
) do |page| %>
  
  <%= form_with model: [:admin, @professional], local: true do |form| %>
    <%= page.with_sections do %>
      <%= render Ui::FormSectionComponent.new(title: "Dados Pessoais") do |section| %>
        <%= section.with_fields do %>
          <div class="md:col-span-2">
            <%= form.label :full_name, "Nome Completo *", class: "mb-1.5 block text-sm font-medium text-gray-700 dark:text-gray-400" %>
            <%= form.text_field :full_name, 
                class: "dark:bg-dark-900 shadow-theme-xs focus:border-brand-300 focus:ring-brand-500/10 dark:focus:border-brand-800 h-11 w-full rounded-lg border border-gray-300 bg-transparent px-4 py-2.5 text-sm text-gray-800 placeholder:text-gray-400 focus:ring-3 focus:outline-hidden dark:border-gray-700 dark:bg-gray-900 dark:text-white/90 dark:placeholder:text-white/30",
                placeholder: "Digite o nome completo",
                required: true %>
          </div>
          
          <!-- Mais campos... -->
        <% end %>
      <% end %>
    <% end %>

    <%= page.with_form_actions do %>
      <%= render Ui::FormActionsComponent.new(
        cancel_path: admin_professionals_path,
        submit_text: "Criar Profissional"
      ) %>
    <% end %>
  <% end %>
<% end %>
```

## Exemplo Completo - Tela Show

```erb
<%= render Ui::ShowPageComponent.new(
  model: @professional,
  back_path: admin_professionals_path,
  title: "Detalhes do Profissional",
  subtitle: "Visualize as informações do profissional"
) do |page| %>
  
  <%= page.with_sections do %>
    <%= render Ui::ShowSectionComponent.new(title: "Dados Pessoais") do |section| %>
      <%= section.with_fields do %>
        <div class="md:col-span-2">
          <span class="mb-1.5 block text-sm font-medium text-gray-700 dark:text-gray-400">Nome Completo</span>
          <p class="h-11 w-full rounded-lg border border-gray-300 bg-gray-50 px-4 py-2.5 text-sm text-gray-800 dark:border-gray-700 dark:bg-gray-900 dark:text-white/90">
            <%= @professional.full_name %>
          </p>
        </div>
        
        <!-- Mais campos... -->
      <% end %>
    <% end %>
  <% end %>

  <%= page.with_page_actions(edit_path: edit_admin_professional_path(@professional)) %>
<% end %>
```

## Exemplo - Tabela com Ícones Diretos 🆕

```erb
<table class="w-full">
  <thead>
    <tr>
      <th>Nome</th>
      <th>Email</th>
      <th class="text-right">Ações</th>
    </tr>
  </thead>
  <tbody>
    <% @professionals.each do |professional| %>
      <tr>
        <td><%= professional.full_name %></td>
        <td><%= professional.email %></td>
        <%= render Ui::TableActionsComponent.new(
          model: professional,
          resource_name: "professional"
        ) %>
      </tr>
    <% end %>
  </tbody>
</table>
```

## Vantagens

1. **Padronização**: Todas as telas seguem exatamente o mesmo padrão
2. **Manutenibilidade**: Mudanças no padrão são feitas em um só lugar
3. **Reutilização**: Componentes podem ser usados em qualquer recurso
4. **Consistência**: Layout, classes CSS e estrutura sempre iguais
5. **Flexibilidade**: Permite customizações quando necessário
6. **UX Melhorada**: Ícones diretos são mais intuitivos e rápidos
7. **Mobile First**: Melhor experiência em dispositivos móveis
8. **Moderno**: Segue padrões atuais de interface

## Como Aplicar

1. **Identifique** o padrão atual das telas de profissionais
2. **Substitua** o código hardcoded pelos componentes
3. **Organize** os campos em seções lógicas
4. **Configure** títulos, subtítulos e caminhos
5. **Atualize** tabelas para usar ícones diretos
6. **Teste** para garantir que tudo funciona

## Resultado

- ✅ **100% padronizado** com profissionais
- ✅ **Código limpo** e organizado
- ✅ **Fácil manutenção** e evolução
- ✅ **Consistência visual** em todo o sistema
- ✅ **Reutilização** para novos recursos
- ✅ **UX moderna** com ícones diretos
- ✅ **Mobile friendly** e responsivo
- ✅ **Padrão profissional** de interface
