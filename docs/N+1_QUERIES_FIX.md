# 🔍 Correção de N+1 Queries - IntegrarPlus

**Data**: 28 de Outubro de 2025
**Status**: 🔧 Em Progresso

---

## 📊 N+1 Queries Detectados pelo Bullet

### ✅ CORRIGIDOS

#### 1. Groups Controller
**Local**: `app/controllers/admin/groups_controller.rb:91`
**Problema**: `Group => [:permissions, :group_permissions]`
**Solução**:
```ruby
# ANTES
Group.includes(:permissions).order(created_at: :desc)

# DEPOIS
Group.includes(:permissions, :group_permissions).order(created_at: :desc)
```
**Status**: ✅ Corrigido

---

#### 2. Beneficiaries Controller (Search Results)
**Local**: `app/controllers/admin/beneficiaries_controller.rb:23`
**Problema**: `Beneficiary => [:anamneses, :portal_intake]`
**Solução**:
```ruby
# ANTES
@beneficiaries = search_results[offset, per_page] || []

# DEPOIS
beneficiary_ids = search_results[offset, per_page].map(&:id)
@beneficiaries = Beneficiary.includes(:anamneses, :portal_intake).where(id: beneficiary_ids)
```
**Status**: ✅ Corrigido

---

### 🔧 EM ANÁLISE

Os controllers abaixo JÁ TÊM includes, mas Bullet está detectando problemas.
Precisa verificar:
1. Se as views estão acessando associações não carregadas
2. Se os resultados de busca perdem os includes
3. Se há loops nas views acessando associações

#### Controllers com includes existentes:
- ✅ `anamneses_controller.rb` - includes(:beneficiary, :professional, :portal_intake)
- ✅ `professionals_controller.rb` - includes(:user, :groups, :specialities, :specializations, :contract_type)
- ✅ `workspace_controller.rb` - includes(:author, :document_versions, :document_responsibles)
- ✅ `released_documents_controller.rb` - includes(:author, :document_versions, :document_responsibles)
- ✅ `flow_charts_controller.rb` - includes(:created_by, :current_version)
- ✅ `specializations_controller.rb` - includes(:specialities)
- ✅ `agendas_controller.rb` - includes(:unit, :created_by, :professionals)

---

## 🎯 PRÓXIMOS PASSOS

### Passo 1: Verificar Views
Analisar as views para identificar quais associações estão sendo acessadas:
- `app/views/admin/groups/_table.html.erb`
- `app/views/admin/beneficiaries/_table.html.erb`
- Outras views de listagem

### Passo 2: Verificar Partials
Verificar se os partials acessam associações não carregadas.

### Passo 3: Adicionar includes faltantes
Baseado na análise das views, adicionar os includes necessários.

### Passo 4: Testar
Navegar por todas as páginas e verificar se o Bullet ainda detecta problemas.

---

## 📝 GUIA DE CORREÇÃO

### Como identificar o que incluir:

1. **Ler o alerta do Bullet**:
   ```
   Beneficiary => [:anamneses, :portal_intake]
   Remove from your query: .includes([:anamneses, :portal_intake])
   ```

2. **Adicionar no controller**:
   ```ruby
   @beneficiaries = Beneficiary.includes(:anamneses, :portal_intake).all
   ```

3. **Para buscas com MeiliSearch**:
   ```ruby
   # Recarregar com includes após a busca
   ids = search_results.map(&:id)
   @records = Model.includes(:associations).where(id: ids)
   ```

---

## 🔧 TEMPLATE DE CORREÇÃO

```ruby
# Para queries simples
def index
  @records = Model.includes(:association1, :association2).all
end

# Para buscas com MeiliSearch
def index
  if params[:query].present?
    search_results = search_service.search(params[:query])
    ids = search_results.map(&:id)
    @records = Model.includes(:association1, :association2).where(id: ids)
  else
    @records = Model.includes(:association1, :association2).all
  end
end

# Para associações aninhadas
@records = Model.includes(association: :nested_association).all
```

---

**Última atualização**: 28 de Outubro de 2025
**Progresso**: 2 problemas corrigidos, análise em andamento
