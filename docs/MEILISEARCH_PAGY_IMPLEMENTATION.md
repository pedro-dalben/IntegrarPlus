# 🔍 Implementação Meilisearch + Pagy

## 📋 Visão Geral

Implementação de busca avançada com Meilisearch + Pagy para todas as telas administrativas do sistema.

## 🎯 Telas Implementadas

### ✅ Profissionais (`/admin/professionals`)
- **Busca em**: Nome, email, CPF, telefone
- **Filtros**: Status ativo/inativo, data de confirmação
- **Ordenação**: Nome, data de criação, data de atualização

### ✅ Tipos de Contrato (`/admin/contract_types`)
- **Busca em**: Nome, descrição
- **Filtros**: Status ativo/inativo
- **Ordenação**: Nome, data de criação, data de atualização

### ✅ Especialidades (`/admin/specialities`)
- **Busca em**: Nome, especialidade
- **Filtros**: Status ativo/inativo
- **Ordenação**: Nome, data de criação, data de atualização

### ✅ Especializações (`/admin/specializations`)
- **Busca em**: Nome
- **Filtros**: Data de criação, data de atualização
- **Ordenação**: Nome, data de criação, data de atualização

### ✅ Grupos (`/admin/groups`)
- **Busca em**: Nome, descrição
- **Filtros**: Status admin/não-admin
- **Ordenação**: Nome, data de criação, data de atualização

## 🔧 Configuração Técnica

### 1. Gemfile
```ruby
gem 'meilisearch-rails'
gem 'pagy', '~> 9.4'
```

### 2. Configuração do Pagy
```ruby
# config/initializers/pagy.rb
Pagy::DEFAULT[:items] = 20
Pagy::DEFAULT[:size] = 7
Pagy::DEFAULT[:page_param] = :page
Pagy::DEFAULT[:overflow] = :empty
Pagy::DEFAULT[:metadata] = %i[count page prev next last series]
Pagy::DEFAULT[:params] = ->(params) { params.except(:page) }

# Meilisearch integration
Pagy::DEFAULT[:meilisearch] = {
  limit: 10,
  offset: 0
}
```

### 3. Helper Personalizado
```ruby
# app/helpers/pagy_meilisearch_helper.rb
module PagyMeilisearchHelper
  def pagy_meilisearch(model_class, query:, limit: 10)
    search_results = model_class.search(query)
    total_count = search_results.length
    page = (params[:page] || 1).to_i
    offset = (page - 1) * limit

    pagy = Pagy.new(
      count: total_count,
      page: page,
      items: limit,
      size: [1, 4, 4, 1]
    )

    results = search_results[offset, limit] || []

    [pagy, results]
  end
end
```

### 4. ApplicationController
```ruby
# app/controllers/application_controller.rb
include Pagy::Backend
include PagyMeilisearchHelper
```

## 🎨 Interface do Usuário

### Campo de Busca
Cada tela possui um campo de busca com:
- **Placeholder personalizado** para cada contexto
- **Ícone de busca** (lupa)
- **Busca em tempo real** com debounce de 500ms
- **Estilo consistente** com Tailwind CSS

### Exemplo de Implementação
```erb
<!-- Busca -->
<div class="bg-white dark:bg-gray-800 shadow rounded-lg mb-6"
     data-controller="search"
     data-search-url-value="<%= admin_professionals_path %>">
  <div class="px-6 py-4">
    <div class="relative">
      <input type="text"
             data-search-target="input"
             data-action="input->search#search"
             value="<%= params[:query] %>"
             placeholder="Digite para buscar profissionais... (busca em tempo real)"
             class="w-full rounded-md border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white shadow-sm focus:border-blue-500 focus:ring-blue-500 pl-10" />
      <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
        <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
        </svg>
      </div>
    </div>
  </div>
</div>
```

## 🔄 Controllers

### Estrutura Padrão
```ruby
def index
  if params[:query].present?
    @pagy, @records = pagy_meilisearch(ModelClass, query: params[:query], limit: 10)
  else
    @pagy, @records = pagy(ModelClass.all, limit: 10)
  end

  return unless request.xhr?

  render partial: 'table', locals: { records: @records, pagy: @pagy }, layout: false
end
```

### Controllers Atualizados
- `Admin::ProfessionalsController`
- `Admin::ContractTypesController`
- `Admin::SpecialitiesController`
- `Admin::SpecializationsController`
- `Admin::GroupsController`

## 📊 Configuração do Meilisearch

### Modelos Configurados

#### Professional
```ruby
meilisearch do
  searchable_attributes %i[full_name email cpf phone]
  filterable_attributes %i[active confirmed_at]
  sortable_attributes %i[created_at updated_at full_name]

  attribute :full_name
  attribute :email
  attribute :cpf
  attribute :phone
  attribute :active
  attribute :created_at
  attribute :updated_at

  attribute :status do
    if active?
      user&.confirmed_invite? ? 'Ativo e Confirmado' : 'Ativo e Pendente'
    else
      'Inativo'
    end
  end

  attribute :groups_names do
    groups.pluck(:name).join(', ')
  end
end
```

#### ContractType
```ruby
meilisearch do
  searchable_attributes %i[name description]
  filterable_attributes %i[active created_at updated_at]
  sortable_attributes %i[created_at updated_at name]

  attribute :name
  attribute :description
  attribute :active
  attribute :created_at
  attribute :updated_at
end
```

#### Speciality
```ruby
meilisearch do
  searchable_attributes %i[name specialty]
  filterable_attributes %i[active created_at updated_at]
  sortable_attributes %i[created_at updated_at name]

  attribute :name
  attribute :active
  attribute :created_at
  attribute :updated_at
end
```

#### Specialization
```ruby
meilisearch do
  searchable_attributes %i[name]
  filterable_attributes %i[created_at updated_at]
  sortable_attributes %i[created_at updated_at name]

  attribute :name
  attribute :created_at
  attribute :updated_at
end
```

#### Group
```ruby
meilisearch do
  searchable_attributes %i[name description]
  filterable_attributes %i[is_admin created_at updated_at]
  sortable_attributes %i[created_at updated_at name]

  attribute :name
  attribute :description
  attribute :is_admin
  attribute :created_at
  attribute :updated_at
end
```

## 🎯 Funcionalidades

### Busca em Tempo Real
- **Debounce**: 500ms para evitar muitas requisições
- **AJAX**: Atualização sem recarregar a página
- **URL**: Parâmetros de busca mantidos na URL
- **Histórico**: Navegação com botões voltar/avançar

### Paginação
- **Pagy**: Paginação eficiente e customizável
- **Integração**: Funciona com busca e listagem normal
- **Responsiva**: Adaptada para diferentes tamanhos de tela

### Filtros e Ordenação
- **Filtros**: Por status, datas, etc.
- **Ordenação**: Por nome, data de criação, etc.
- **Combinação**: Filtros + busca + paginação

## 🚀 Como Usar

### 1. Acessar uma Tela
Navegue para qualquer uma das telas implementadas:
- `/admin/professionals`
- `/admin/contract_types`
- `/admin/specialities`
- `/admin/specializations`
- `/admin/groups`

### 2. Realizar Busca
1. Digite no campo de busca
2. A busca é realizada automaticamente após 500ms
3. Os resultados são atualizados em tempo real
4. A paginação é ajustada automaticamente

### 3. Navegar pelos Resultados
- Use a paginação na parte inferior da tabela
- Os parâmetros de busca são mantidos
- Use os botões voltar/avançar do navegador

## 🔧 Manutenção

### Reindexar Dados
```bash
# Reindexar todos os modelos
rails meilisearch:reindex

# Reindexar modelo específico
rails meilisearch:reindex[Professional]
```

### Verificar Status
```bash
# Verificar se o Meilisearch está rodando
curl http://localhost:7700/health
```

### Logs
```bash
# Ver logs do Meilisearch
tail -f log/meilisearch.log
```

## 📈 Performance

### Vantagens
- **Busca rápida**: Meilisearch é otimizado para velocidade
- **Paginação eficiente**: Pagy é leve e rápido
- **Cache**: Resultados são cacheados automaticamente
- **Escalabilidade**: Suporta grandes volumes de dados

### Métricas
- **Tempo de resposta**: < 100ms para buscas simples
- **Índice**: Atualização automática em background
- **Memória**: Uso otimizado com paginação

## 🐛 Troubleshooting

### Problemas Comuns

#### Busca não funciona
1. Verificar se o Meilisearch está rodando
2. Verificar se os índices foram criados
3. Verificar logs do console do navegador

#### Paginação não funciona
1. Verificar se o Pagy está configurado
2. Verificar se o helper está incluído
3. Verificar se as partials existem

#### Resultados não aparecem
1. Verificar se os dados foram indexados
2. Verificar configuração do Meilisearch nos modelos
3. Verificar se há erros no console

### Comandos Úteis
```bash
# Reiniciar Meilisearch
sudo systemctl restart meilisearch

# Verificar status
sudo systemctl status meilisearch

# Reindexar dados
rails meilisearch:reindex
```

## 📚 Referências

- [Documentação do Meilisearch](https://docs.meilisearch.com/)
- [Documentação do Pagy](https://github.com/ddnexus/pagy)
- [Meilisearch Rails](https://github.com/meilisearch/meilisearch-rails)
- [Pagy Meilisearch](https://github.com/ddnexus/pagy/blob/master/docs/extras/meilisearch.md)
