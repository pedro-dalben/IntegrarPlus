# Troubleshooting - Salvamento de Formulários

## Problema: Campos não são salvos ao submeter formulário

### Sintomas
- Campos de endereço não são salvos
- Grupos, especialidades e especializações não são associados
- Formulário é submetido mas dados não persistem
- Erros de validação não aparecem

### Causas Comuns

#### 1. **Parâmetros não permitidos no controller**
**Problema**: O método `permit` não inclui todos os parâmetros necessários.

**Solução**: Verificar se todos os parâmetros estão sendo permitidos no controller.

```ruby
def professional_params
  params.require(:professional).permit(
    :full_name, :email, :cpf, :phone, :active,
    { primary_address_attributes: [
        :id, :zip_code, :street, :number, :complement,
        :neighborhood, :city, :state, :latitude, :longitude, :_destroy
      ],
      group_ids: [], 
      speciality_ids: [], 
      specialization_ids: []
    }
  )
end
```

#### 2. **Relacionamentos não configurados no modelo**
**Problema**: O modelo não tem `accepts_nested_attributes_for` configurado.

**Solução**: Adicionar configuração para nested attributes.

```ruby
class Professional < ApplicationRecord
  # Relacionamentos
  has_many :groups, through: :professional_groups
  has_many :specialities, through: :professional_specialities
  has_many :specializations, through: :professional_specializations
  
  # Nested attributes
  accepts_nested_attributes_for :primary_address, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :groups, allow_destroy: true
  accepts_nested_attributes_for :specialities, allow_destroy: true
  accepts_nested_attributes_for :specializations, allow_destroy: true
end
```

#### 3. **Nomes de campos incorretos no formulário**
**Problema**: Os campos do formulário não seguem a convenção Rails para nested attributes.

**Solução**: Usar nomes corretos para os campos.

```erb
<!-- Endereço -->
<%= form.fields_for :primary_address do |af| %>
  <%= af.text_field :zip_code %>
  <%= af.text_field :street %>
  <%= af.text_field :number %>
  <%= af.text_field :neighborhood %>
  <%= af.text_field :city %>
  <%= af.select :state, options_for_select([...]) %>
<% end %>

<!-- Seleções múltiplas -->
<%= form.select :group_ids, @groups.map { |g| [g.name, g.id] }, 
    { prompt: "Selecione os grupos..." }, { multiple: true } %>

<%= form.select :speciality_ids, @specialities.map { |s| [s.name, s.id] }, 
    { prompt: "Selecione as especialidades..." }, { multiple: true } %>

<%= form.select :specialization_ids, [], 
    { prompt: "Selecione as especializações..." }, { multiple: true } %>
```

#### 4. **Validações impedindo salvamento**
**Problema**: Validações no modelo impedem o salvamento.

**Solução**: Verificar logs de erro e ajustar validações.

```ruby
# No controller
def create
  @professional = Professional.new(professional_params)
  
  if @professional.save
    redirect_to @professional, notice: 'Profissional criado com sucesso!'
  else
    Rails.logger.error "Erros de validação: #{@professional.errors.full_messages}"
    render :new, status: :unprocessable_entity
  end
end
```

### 5. **Relacionamentos incorretos no modelo**
**Problema**: O modelo usa métodos de relacionamento que não existem.

**Solução**: Verificar se os relacionamentos estão configurados corretamente.

```ruby
# ❌ ERRADO: Método singular não existe
specialization.speciality

# ✅ CORRETO: Método plural existe
specialization.specialities

# Exemplo de validação correta
def specialization_consistency
  return unless specializations.any?

  specializations.each do |specialization|
    # Verificar se a especialização tem alguma especialidade em comum
    specialization_speciality_ids = specialization.specialities.pluck(:id)
    common_specialities = speciality_ids & specialization_speciality_ids
    
    if common_specialities.empty?
      errors.add(:specializations,
                 "especialização '#{specialization.name}' não pertence a nenhuma especialidade selecionada")
    end
  end
end
```

### 6. **Validações complexas com relacionamentos**
**Problema**: Validações que dependem de relacionamentos many-to-many podem falhar.

**Solução**: Implementar validações robustas com logs para debug.

```ruby
def specialization_consistency
  return unless specializations.any?

  Rails.logger.info "Validando consistência de especializações..."
  Rails.logger.info "Especialidades selecionadas: #{speciality_ids.inspect}"
  Rails.logger.info "Especializações selecionadas: #{specialization_ids.inspect}"

  specializations.each do |specialization|
    Rails.logger.info "Verificando especialização: #{specialization.name}"
    
    specialization_speciality_ids = specialization.specialities.pluck(:id)
    common_specialities = speciality_ids & specialization_speciality_ids
    
    if common_specialities.empty?
      error_msg = "especialização '#{specialization.name}' não pertence a nenhuma especialidade selecionada"
      Rails.logger.warn "Erro de validação: #{error_msg}"
      errors.add(:specializations, error_msg)
    end
  end
end
```

### Debug e Verificação

#### 1. **Verificar Parâmetros no Controller**
```ruby
def create
  Rails.logger.info "Parâmetros recebidos: #{params[:professional].inspect}"
  Rails.logger.info "Parâmetros processados: #{professional_params.inspect}"
  
  @professional = Professional.new(professional_params)
  # ... resto do código
end
```

#### 2. **Verificar Logs do Rails**
```bash
# No terminal
tail -f log/development.log

# Procurar por:
# - Parâmetros recebidos
# - Erros de validação
# - SQL gerado
```

#### 3. **Verificar Console do Navegador**
```javascript
// No console do navegador
// Verificar se há erros JavaScript
// Verificar se os campos estão sendo preenchidos
```

#### 4. **Verificar Network Tab**
- Abrir DevTools
- Ir para aba Network
- Submeter formulário
- Verificar requisição POST
- Verificar parâmetros enviados

### Estrutura Correta do Formulário

#### Formulário Principal
```erb
<%= form_with model: [:admin, professional], local: true do |form| %>
  <!-- Campos básicos -->
  <%= form.text_field :full_name %>
  <%= form.email_field :email %>
  <%= form.text_field :cpf %>
  
  <!-- Endereço aninhado -->
  <%= render AddressFormComponent.new(form: form, show_coordinates: true) %>
  
  <!-- Seleções múltiplas -->
  <%= form.select :group_ids, @groups.map { |g| [g.name, g.id] }, 
      { prompt: "Selecione os grupos..." }, { multiple: true } %>
  
  <%= form.select :speciality_ids, @specialities.map { |s| [s.name, s.id] }, 
      { prompt: "Selecione as especialidades..." }, { multiple: true } %>
  
  <%= form.select :specialization_ids, [], 
      { prompt: "Selecione as especializações..." }, { multiple: true } %>
  
  <%= form.submit %>
<% end %>
```

#### Componente de Endereço
```erb
<% form.fields_for :primary_address do |af| %>
  <div class="form-group">
    <%= af.label :zip_code, "CEP" %>
    <%= af.text_field :zip_code %>
  </div>
  
  <div class="form-group">
    <%= af.label :street, "Rua" %>
    <%= af.text_field :street %>
  </div>
  
  <!-- Outros campos... -->
<% end %>
```

### Checklist de Verificação

- [ ] Controller permite todos os parâmetros necessários
- [ ] Modelo tem `accepts_nested_attributes_for` configurado
- [ ] Formulário usa nomes corretos para campos
- [ ] Não há erros JavaScript no console
- [ ] Requisição POST está sendo enviada corretamente
- [ ] Logs do Rails mostram parâmetros recebidos
- [ ] Validações do modelo não estão impedindo salvamento
- [ ] Relacionamentos estão configurados corretamente

### Exemplo de Controller Completo

```ruby
class Admin::ProfessionalsController < ApplicationController
  def create
    @professional = Professional.new(professional_params)
    
    Rails.logger.info "Parâmetros recebidos: #{params[:professional].inspect}"
    Rails.logger.info "Parâmetros processados: #{professional_params.inspect}"
    
    if @professional.save
      redirect_to @professional, notice: 'Profissional criado com sucesso!'
    else
      Rails.logger.error "Erros de validação: #{@professional.errors.full_messages}"
      load_form_data
      render :new, status: :unprocessable_entity
    end
  end
  
  private
  
  def professional_params
    params.require(:professional).permit(
      :full_name, :birth_date, :cpf, :phone, :email, :active,
      :contract_type_id, :hired_on, :workload_hhmm, :workload_minutes,
      :council_code, :company_name, :cnpj,
      { primary_address_attributes: [
          :id, :zip_code, :street, :number, :complement,
          :neighborhood, :city, :state, :latitude, :longitude, :_destroy
        ],
        secondary_address_attributes: [
          :id, :zip_code, :street, :number, :complement,
          :neighborhood, :city, :state, :latitude, :longitude, :_destroy
        ],
        group_ids: [], 
        speciality_ids: [], 
        specialization_ids: []
      }
    )
  end
  
  def load_form_data
    @contract_types = ContractType.active.ordered
    @groups = Group.ordered
    @specialities = Speciality.active.ordered
  end
end
```

### Exemplo de Modelo Completo

```ruby
class Professional < ApplicationRecord
  # Relacionamentos
  has_many :professional_groups, dependent: :destroy
  has_many :groups, through: :professional_groups
  
  has_many :professional_specialities, dependent: :destroy
  has_many :specialities, through: :professional_specialities
  
  has_many :professional_specializations, dependent: :destroy
  has_many :specializations, through: :professional_specializations
  
  # Nested attributes
  accepts_nested_attributes_for :primary_address, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :secondary_address, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :groups, allow_destroy: true
  accepts_nested_attributes_for :specialities, allow_destroy: true
  accepts_nested_attributes_for :specializations, allow_destroy: true
  
  # Validações
  validates :full_name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :cpf, presence: true, uniqueness: true
end
```

### Conclusão

Para resolver problemas de salvamento de formulários:

1. **Verificar parâmetros** no controller
2. **Configurar nested attributes** no modelo
3. **Usar nomes corretos** nos campos do formulário
4. **Adicionar logs** para debug
5. **Verificar validações** e relacionamentos
6. **Testar isoladamente** cada parte do formulário

**Regra de Ouro**: Sempre verificar os logs do Rails para entender o que está sendo recebido e processado.
