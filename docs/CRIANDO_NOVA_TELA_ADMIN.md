# 📋 Guia Completo: Criando uma Nova Tela Admin

Este guia explica como criar uma nova tela administrativa seguindo as convenções do projeto IntegrarPlus.

## 🎯 Visão Geral

Para criar uma nova tela admin, você precisará criar:
1. **Model** (se não existir)
2. **Controller** 
3. **Views** (index, show, new, edit)
4. **Traduções**
5. **Menu** (sidebar)
6. **Rotas**

## 📁 Estrutura de Arquivos

```
app/
├── models/
│   └── [resource].rb
├── controllers/
│   └── admin/
│       └── [resources]_controller.rb
├── views/
│   └── admin/
│       └── [resources]/
│           ├── index.html.erb
│           ├── show.html.erb
│           ├── new.html.erb
│           └── edit.html.erb
└── components/
    └── ui/
        └── sidebar_component.html.erb

config/
├── routes.rb
└── locales/
    └── admin/
        └── [resources].pt-BR.yml
```

## 🚀 Passo a Passo

### 1. 📝 Criar o Model (se necessário)

```ruby
# app/models/example.rb
class Example < ApplicationRecord
  include MeiliSearch::Rails
  
  validates :name, presence: true
  
  meilisearch do
    searchable_attributes [:name, :description]
    filterable_attributes [:active]
    sortable_attributes [:created_at, :name]
  end
  
  scope :active, -> { where(active: true) }
end
```

### 2. 🎮 Criar o Controller

```ruby
# app/controllers/admin/examples_controller.rb
class Admin::ExamplesController < Admin::BaseController
  before_action :set_example, only: [:show, :edit, :update, :destroy]

  def index
    @pagy, @examples = if params[:query].present?
      pagy(Example.search(params[:query]))
    else
      pagy(Example.all)
    end
  end

  def show
  end

  def new
    @example = Example.new
  end

  def edit
  end

  def create
    @example = Example.new(example_params)

    if @example.save
      redirect_to admin_example_path(@example), notice: 'Example criado com sucesso.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @example.update(example_params)
      redirect_to admin_example_path(@example), notice: 'Example atualizado com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @example.destroy
    redirect_to admin_examples_path, notice: 'Example excluído com sucesso.'
  end

  private

  def set_example
    @example = Example.find(params[:id])
  end

  def example_params
    params.require(:example).permit(:name, :description, :active)
  end
end
```

### 3. 🎨 Criar as Views

#### Index View
```erb
<!-- app/views/admin/examples/index.html.erb -->
<%= render Ui::DataTableComponent.new(searchable: false) do |component| %>
  <% component.with_actions do %>
    <%= link_to new_admin_example_path, class: "bg-blue-600 hover:bg-blue-700 inline-flex items-center justify-center gap-2 rounded-lg px-4 py-2 text-sm font-medium text-white transition" do %>
      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"/>
      </svg>
      Novo Example
    <% end %>
  <% end %>

  <div data-controller="search" 
       data-search-url-value="<%= admin_examples_path %>"
       data-search-debounce-value="500">
    
    <!-- Campo de busca -->
    <div class="mb-4">
      <div class="relative">
        <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
          <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
          </svg>
        </div>
        <input type="text" 
               placeholder="Buscar examples..." 
               class="h-11 w-full rounded-lg border border-gray-300 bg-white py-2.5 pr-4 pl-10 text-sm text-gray-800 placeholder:text-gray-400 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:border-gray-700 dark:bg-gray-800 dark:text-white dark:placeholder:text-gray-400"
               data-search-target="input"
               data-action="input->search#search">
      </div>
    </div>

    <table class="w-full table-auto">
      <thead>
        <tr class="border-b border-gray-200 dark:divide-gray-800 dark:border-gray-800">
          <th class="px-5 py-4 text-left text-sm font-medium text-gray-800 dark:text-white">
            Nome
          </th>
          <th class="px-5 py-4 text-left text-sm font-medium text-gray-800 dark:text-white">
            Status
          </th>
          <th class="px-5 py-4 text-left text-sm font-medium text-gray-800 dark:text-white">
            Criado em
          </th>
          <th class="px-5 py-4 text-right text-sm font-medium text-gray-800 dark:text-white">
            Ações
          </th>
        </tr>
      </thead>
      <tbody class="divide-x divide-y divide-gray-200 dark:divide-gray-800" data-search-target="results">
        <% @examples.each do |example| %>
          <tr class="transition hover:bg-gray-50 dark:hover:bg-gray-900"
              data-search-target="row"
              data-action="click->row#navigate"
              data-url="<%= admin_example_path(example) %>">
            <td class="px-5 py-4 whitespace-nowrap">
              <div class="flex items-center gap-3">
                <div class="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center dark:bg-blue-900/20">
                  <svg class="w-5 h-5 text-blue-600 dark:text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
                  </svg>
                </div>
                <div>
                  <h6 class="text-sm font-medium text-gray-800 dark:text-white">
                    <%= example.name %>
                  </h6>
                </div>
              </div>
            </td>
            <td class="px-5 py-4 whitespace-nowrap">
              <% if example.active? %>
                <span class="text-theme-xs rounded-full bg-green-50 px-2 py-0.5 font-medium text-green-700 dark:bg-green-500/15 dark:text-green-500">
                  Ativo
                </span>
              <% else %>
                <span class="text-theme-xs rounded-full bg-red-50 px-2 py-0.5 font-medium text-red-700 dark:bg-red-500/15 dark:text-red-500">
                  Inativo
                </span>
              <% end %>
            </td>
            <td class="px-5 py-4 whitespace-nowrap text-sm text-gray-600 dark:text-gray-400">
              <%= l(example.created_at, format: :short) %>
            </td>
            <td class="px-5 py-4 whitespace-nowrap text-right">
              <div class="flex items-center justify-end gap-2" data-controller="dropdown">
                <button class="p-2 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 transition-colors"
                        data-action="click->dropdown#toggle"
                        type="button">
                  <svg class="w-5 h-5 fill-current" viewBox="0 0 24 24">
                    <path d="M12 13a1 1 0 100-2 1 1 0 000 2zM19 13a1 1 0 100-2 1 1 0 000 2zM5 13a1 1 0 100-2 1 1 0 000 2z"/>
                  </svg>
                </button>
                <div data-dropdown-target="panel"
                     class="absolute right-0 mt-2 w-48 rounded-lg border border-gray-200 bg-white shadow-lg hidden dark:border-gray-700 dark:bg-gray-800 z-50">
                  <div class="py-1">
                    <%= link_to admin_example_path(example), 
                        class: "flex items-center gap-2 px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 dark:text-gray-300 dark:hover:bg-gray-700" do %>
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                      </svg>
                      Ver
                    <% end %>
                    <%= link_to edit_admin_example_path(example), 
                        class: "flex items-center gap-2 px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 dark:text-gray-300 dark:hover:bg-gray-700" do %>
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/>
                      </svg>
                      Editar
                    <% end %>
                    <%= link_to admin_example_path(example), 
                        method: :delete,
                        data: { confirm: 'Tem certeza que deseja excluir este example?' },
                        class: "flex items-center gap-2 px-4 py-2 text-sm text-red-600 hover:bg-red-50 dark:text-red-400 dark:hover:bg-red-900/20" do %>
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
                      </svg>
                      Excluir
                    <% end %>
                  </div>
                </div>
              </div>
            </td>
          </tr>
        <% end %>
      </tbody>
    </table>

    <!-- Paginação -->
    <% content_for :pagination do %>
      <div class="flex items-center justify-between">
        <div class="text-sm text-gray-600 dark:text-gray-400">
          Mostrando <%= @pagy.from %> a <%= @pagy.to %> de <%= @pagy.count %> resultados
        </div>
        <div class="flex items-center gap-2">
          <%= pagy_nav(@pagy) %>
        </div>
      </div>
    <% end %>
  </div>
<% end %>
```

#### Show View
```erb
<!-- app/views/admin/examples/show.html.erb -->
<div class="bg-white dark:bg-gray-800 rounded-xl border border-gray-200 dark:border-gray-700 shadow-sm p-6">
  <div class="flex items-center justify-between mb-6">
    <div>
      <h3 class="text-lg font-semibold text-gray-800 dark:text-white">
        <%= @example.name %>
      </h3>
      <p class="text-sm text-gray-600 dark:text-gray-400">
        Detalhes do example
      </p>
    </div>
    <div class="flex items-center gap-2">
      <%= link_to edit_admin_example_path(@example), class: "bg-blue-600 hover:bg-blue-700 inline-flex items-center justify-center gap-2 rounded-lg px-4 py-2 text-sm font-medium text-white transition" do %>
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/>
        </svg>
        Editar
      <% end %>
      <%= link_to admin_examples_path, class: "bg-gray-600 hover:bg-gray-700 inline-flex items-center justify-center gap-2 rounded-lg px-4 py-2 text-sm font-medium text-white transition" do %>
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"/>
        </svg>
        Voltar
      <% end %>
    </div>
  </div>

  <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
    <div>
      <h4 class="text-sm font-medium text-gray-500 dark:text-gray-400 mb-2">Nome</h4>
      <p class="text-gray-800 dark:text-white"><%= @example.name %></p>
    </div>
    
    <div>
      <h4 class="text-sm font-medium text-gray-500 dark:text-gray-400 mb-2">Status</h4>
      <% if @example.active? %>
        <span class="text-theme-xs rounded-full bg-green-50 px-2 py-0.5 font-medium text-green-700 dark:bg-green-500/15 dark:text-green-500">
          Ativo
        </span>
      <% else %>
        <span class="text-theme-xs rounded-full bg-red-50 px-2 py-0.5 font-medium text-red-700 dark:bg-red-500/15 dark:text-red-500">
          Inativo
        </span>
      <% end %>
    </div>
    
    <div class="md:col-span-2">
      <h4 class="text-sm font-medium text-gray-500 dark:text-gray-400 mb-2">Descrição</h4>
      <p class="text-gray-800 dark:text-white"><%= @example.description %></p>
    </div>
    
    <div>
      <h4 class="text-sm font-medium text-gray-500 dark:text-gray-400 mb-2">Criado em</h4>
      <p class="text-gray-800 dark:text-white"><%= l(@example.created_at, format: :long) %></p>
    </div>
    
    <div>
      <h4 class="text-sm font-medium text-gray-500 dark:text-gray-400 mb-2">Atualizado em</h4>
      <p class="text-gray-800 dark:text-white"><%= l(@example.updated_at, format: :long) %></p>
    </div>
  </div>
</div>
```

#### New/Edit Views
```erb
<!-- app/views/admin/examples/new.html.erb -->
<div class="bg-white dark:bg-gray-800 rounded-xl border border-gray-200 dark:border-gray-700 shadow-sm p-6">
  <div class="mb-6">
    <h3 class="text-lg font-semibold text-gray-800 dark:text-white">
      Novo Example
    </h3>
    <p class="text-sm text-gray-600 dark:text-gray-400">
      Preencha os campos abaixo para criar um novo example
    </p>
  </div>

  <%= form_with model: [:admin, @example], local: true, class: "space-y-6" do |form| %>
    <% if @example.errors.any? %>
      <div class="bg-red-50 border border-red-200 rounded-md p-4 dark:bg-red-800/10 dark:border-red-900">
        <div class="flex">
          <div class="flex-shrink-0">
            <svg class="size-4 text-red-400 mt-0.5" xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
              <path d="M16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0zM5.354 4.646a.5.5 0 1 0-.708.708L7.293 8l-2.647 2.646a.5.5 0 0 0 .708.708L8 8.707l2.646 2.647a.5.5 0 0 0 .708-.708L8.707 8l2.647-2.646a.5.5 0 0 0-.708-.708L8 7.293 5.354 4.646z"/>
            </svg>
          </div>
          <div class="ms-3">
            <h3 class="text-sm font-medium text-red-800 dark:text-red-400">
              Erro ao salvar example:
            </h3>
            <div class="mt-2 text-sm text-red-700 dark:text-red-400">
              <ul class="list-disc space-y-1 pl-5">
                <% @example.errors.full_messages.each do |message| %>
                  <li><%= message %></li>
                <% end %>
              </ul>
            </div>
          </div>
        </div>
      </div>
    <% end %>

    <div>
      <%= form.label :name, "Nome", class: "block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2" %>
      <%= form.text_field :name, class: "w-full rounded-lg border border-gray-300 bg-white px-4 py-2.5 text-sm text-gray-800 placeholder:text-gray-400 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:border-gray-700 dark:bg-gray-800 dark:text-white dark:placeholder:text-gray-400" %>
    </div>

    <div>
      <%= form.label :description, "Descrição", class: "block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2" %>
      <%= form.text_area :description, rows: 4, class: "w-full rounded-lg border border-gray-300 bg-white px-4 py-2.5 text-sm text-gray-800 placeholder:text-gray-400 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:border-gray-700 dark:bg-gray-800 dark:text-white dark:placeholder:text-gray-400" %>
    </div>

    <div class="flex items-center">
      <%= form.check_box :active, class: "h-4 w-4 rounded border-gray-300 text-blue-600 focus:ring-blue-500 dark:border-gray-600 dark:bg-gray-800" %>
      <%= form.label :active, "Ativo", class: "ml-2 text-sm text-gray-700 dark:text-gray-300" %>
    </div>

    <div class="flex items-center gap-3">
      <%= form.submit "Salvar", class: "bg-blue-600 hover:bg-blue-700 inline-flex items-center justify-center gap-2 rounded-lg px-4 py-2 text-sm font-medium text-white transition" %>
      <%= link_to "Cancelar", admin_examples_path, class: "bg-gray-600 hover:bg-gray-700 inline-flex items-center justify-center gap-2 rounded-lg px-4 py-2 text-sm font-medium text-white transition" %>
    </div>
  <% end %>
</div>
```

### 4. 🌐 Criar Traduções

```yaml
# config/locales/admin/examples.pt-BR.yml
pt-BR:
  admin:
    breadcrumb:
      example: "Example"
      examples: "Examples"
    pages:
      example:
        index:
          title: "Examples"
          subtitle: "Gerencie os examples disponíveis"
        new:
          title: "Novo Example"
          subtitle: "Cadastre um novo example"
        edit:
          title: "Editar Example"
          subtitle: "Edite as informações do example"
        show:
          title: "Detalhes do Example"
          subtitle: "Visualize as informações do example"
```

### 5. 🧭 Adicionar ao Menu

```erb
<!-- app/components/ui/sidebar_component.html.erb -->
<!-- Adicionar no local apropriado do menu -->
<li>
  <a
    href="/admin/examples"
    class="<%= helpers.sidebar_menu_item_classes('/admin/examples', 'menu-item') %>"
  >
    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
    </svg>

    <span class="menu-item-text">
      Examples
    </span>
  </a>
</li>
```

### 6. 🛣️ Adicionar Rotas

```ruby
# config/routes.rb
namespace :admin do
  resources :examples
end
```

## 🔧 Componentes Automáticos

### Breadcrumb Automático
O breadcrumb é gerado automaticamente baseado no path da URL. Não é necessário configurar nada adicional.

**Exemplos de breadcrumbs gerados:**
- `/admin/examples` → "Início > Examples"
- `/admin/examples/new` → "Início > Examples > Novo Example"
- `/admin/examples/123` → "Início > Examples > Detalhes do Example"
- `/admin/examples/123/edit` → "Início > Examples > Editar Example"

### Paginação Automática
A paginação é configurada automaticamente com 20 itens por página usando Pagy.

### Busca Automática
A busca é integrada automaticamente com Meilisearch (se configurado no model).

## 📋 Checklist de Criação

- [ ] ✅ Model criado com validações
- [ ] ✅ Controller com todas as ações CRUD
- [ ] ✅ Views (index, show, new, edit) criadas
- [ ] ✅ Traduções adicionadas
- [ ] ✅ Menu atualizado
- [ ] ✅ Rotas configuradas
- [ ] ✅ Breadcrumb funcionando automaticamente
- [ ] ✅ Paginação funcionando
- [ ] ✅ Busca funcionando (se aplicável)
- [ ] ✅ Testes criados (opcional)

## 🎨 Personalizações

### Ícones
Substitua o SVG no menu e nas views pelo ícone apropriado para seu recurso.

### Cores
As cores padrão são azuis (`bg-blue-600`). Você pode personalizar conforme necessário.

### Campos
Adicione ou remova campos conforme necessário no formulário e na tabela.

## 🚨 Problemas Comuns

### Breadcrumb não aparece
- Verifique se as traduções estão no arquivo correto
- Confirme se o path está correto

### Paginação não funciona
- Verifique se o controller está usando `pagy()`
- Confirme se o Pagy está incluído no ApplicationController

### Busca não funciona
- Verifique se o model tem Meilisearch configurado
- Confirme se o controller está usando `search()`

## 📚 Recursos Adicionais

- [Documentação do ViewComponent](https://viewcomponent.org/)
- [Documentação do Pagy](https://github.com/ddnexus/pagy)
- [Documentação do Meilisearch](https://docs.meilisearch.com/)
- [Documentação do Tailwind CSS](https://tailwindcss.com/docs)
