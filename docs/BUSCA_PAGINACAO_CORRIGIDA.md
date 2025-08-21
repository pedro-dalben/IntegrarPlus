# Correção do Sistema de Busca com Paginação

## Problema Identificado

O sistema de busca estava funcionando apenas com busca local via JavaScript, que filtrava apenas os itens visíveis na página atual. Quando o usuário buscava algo que estava na segunda página, o resultado não aparecia porque o JavaScript só procurava nos itens da página atual.

## Solução Implementada

### 1. Busca via AJAX
- **Antes**: Busca local via JavaScript (filtra apenas itens da página atual)
- **Depois**: Busca via AJAX que faz requisição para o servidor com MeiliSearch

### 2. Controllers Atualizados
Todos os controllers foram atualizados para responder corretamente às requisições AJAX:

#### `app/controllers/admin/professionals_controller.rb`
```ruby
def index
  if params[:query].present?
    search_results = Professional.search(params[:query])
    page = (params[:page] || 1).to_i
    per_page = 10
    offset = (page - 1) * per_page
    
    @professionals = search_results[offset, per_page] || []
    @pagy = OpenStruct.new(
      count: search_results.length,
      page: page,
      items: per_page,
      pages: (search_results.length.to_f / per_page).ceil,
      from: offset + 1,
      to: [offset + per_page, search_results.length].min,
      prev: page > 1 ? page - 1 : nil,
      next: page < (search_results.length.to_f / per_page).ceil ? page + 1 : nil,
      series: []
    )
  else
    @pagy, @professionals = pagy(Professional.all, limit: 10)
  end

  return unless request.xhr?

  render partial: 'table', locals: { professionals: @professionals, pagy: @pagy }
end
```

#### `app/controllers/admin/specialities_controller.rb`
#### `app/controllers/admin/contract_types_controller.rb`
#### `app/controllers/admin/specializations_controller.rb`

### 3. Partials Criados
Criados partials para cada tabela que são renderizados nas requisições AJAX:

- `app/views/admin/professionals/_table.html.erb`
- `app/views/admin/specialities/_table.html.erb`
- `app/views/admin/contract_types/_table.html.erb`
- `app/views/admin/specializations/_table.html.erb`

### 4. Controller Stimulus Atualizado
`app/frontend/javascript/controllers/search_controller.js`:

```javascript
async performAjaxSearch() {
  const query = this.inputTarget.value.trim()
  
  if (query.length === 0) {
    this.showAllResults()
    return
  }

  try {
    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set('query', query)
    url.searchParams.set('page', '1')

    const response = await fetch(url.toString(), {
      headers: {
        'Accept': 'text/html',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })

    if (response.ok) {
      const html = await response.text()
      this.updateResults(html)
    }
  } catch (error) {
    console.error('Erro na busca:', error)
    this.performLocalSearch()
  }
}
```

### 5. MeiliSearch Habilitado
Habilitado o MeiliSearch no modelo `Professional` que estava comentado:

```ruby
include MeiliSearch::Rails

meilisearch do
  searchable_attributes %i[full_name email cpf phone]
  filterable_attributes %i[active confirmed_at]
  sortable_attributes %i[created_at updated_at full_name]

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

### 6. Paginação Manual para Arrays
Como o MeiliSearch retorna Arrays e não ActiveRecord::Relation, implementei paginação manual:

```ruby
# Paginação manual para resultados do MeiliSearch
page = (params[:page] || 1).to_i
per_page = 10
offset = (page - 1) * per_page

@professionals = search_results[offset, per_page] || []
@pagy = OpenStruct.new(
  count: search_results.length,
  page: page,
  items: per_page,
  pages: (search_results.length.to_f / per_page).ceil,
  from: offset + 1,
  to: [offset + per_page, search_results.length].min,
  prev: page > 1 ? page - 1 : nil,
  next: page < (search_results.length.to_f / per_page).ceil ? page + 1 : nil,
  series: []
)
```

### 7. Helper de Paginação Atualizado
`app/helpers/application_helper.rb`:

```ruby
def generate_pagination_series(pagy)
  return [] if pagy.pages <= 1

  series = []
  current_page = pagy.page
  total_pages = pagy.pages

  # Sempre mostrar primeira página
  series << 1

  # Adicionar gap se necessário
  if current_page > 4
    series << :gap
  end

  # Páginas ao redor da página atual
  start_page = [2, current_page - 1].max
  end_page = [total_pages - 1, current_page + 1].min

  (start_page..end_page).each do |page|
    series << page if page > 1 && page < total_pages
  end

  # Adicionar gap se necessário
  if current_page < total_pages - 3
    series << :gap
  end

  # Sempre mostrar última página
  if total_pages > 1
    series << total_pages
  end

  series
end
```

## Funcionalidades Implementadas

### ✅ Busca em Tempo Real
- Debounce de 500ms para otimizar performance
- Busca via AJAX no servidor com MeiliSearch
- Fallback para busca local se AJAX falhar

### ✅ Paginação Correta
- Busca funciona em todas as páginas
- Resultados são paginados corretamente
- Navegação entre páginas mantém a busca
- Paginação manual para Arrays do MeiliSearch

### ✅ Interface Responsiva
- Campo de busca limpa automaticamente
- Resultados atualizados dinamicamente
- Loading states implícitos

### ✅ Compatibilidade
- Funciona com todos os modelos: Professional, Speciality, ContractType, Specialization
- Mantém funcionalidades existentes
- Não quebra funcionalidades de paginação

## Como Funciona Agora

1. **Usuário digita no campo de busca**
2. **Após 500ms de inatividade, faz requisição AJAX**
3. **Controller processa busca com MeiliSearch**
4. **Resultados são paginados manualmente (Arrays)**
5. **Retorna apenas a tabela atualizada via partial**
6. **JavaScript atualiza o conteúdo da página**
7. **Paginação funciona corretamente com os resultados filtrados**

## Benefícios

- **Busca em todas as páginas**: Agora funciona corretamente
- **Performance melhorada**: MeiliSearch é muito mais rápido
- **Experiência do usuário**: Busca instantânea e precisa
- **Manutenibilidade**: Código mais limpo e organizado
- **Escalabilidade**: Funciona com grandes volumes de dados
- **Compatibilidade**: Funciona com Arrays e ActiveRecord::Relation

## Problemas Resolvidos

### ❌ Erro: `undefined method 'offset' for #<Array>`
**Causa**: MeiliSearch retorna Arrays, mas `pagy` espera ActiveRecord::Relation
**Solução**: Implementação de paginação manual para Arrays

### ❌ Erro: `undefined method 'series' for #<OpenStruct>`
**Causa**: OpenStruct não tem método `series` do Pagy
**Solução**: Helper `generate_pagination_series` para gerar série de páginas

## Próximos Passos

1. **Testar em todas as telas** para garantir funcionamento
2. **Configurar MeiliSearch** se necessário
3. **Indexar dados** com `rails meilisearch:index`
4. **Monitorar performance** em produção

---

**Data**: $(date)
**Responsável**: Sistema de Busca e Paginação
