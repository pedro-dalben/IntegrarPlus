# Componentes do Sistema

## Controllers Stimulus

### Mask Controller

O `MaskController` utiliza a biblioteca IMask para aplicar máscaras em campos de entrada.

#### Instalação

O IMask já está instalado como dependência no projeto:
```json
{
  "dependencies": {
    "imask": "^7.6.1"
  }
}
```

#### Uso

```erb
<div data-controller="mask" data-mask-type-value="cpf">
  <%= f.text_field :cpf, 
      data: { mask_target: "input" } %>
</div>
```

#### Tipos de Máscara Disponíveis

1. **CPF**: `data-mask-type-value="cpf"`
   - Formato: 000.000.000-00

2. **CNPJ**: `data-mask-type-value="cnpj"`
   - Formato: 00.000.000/0000-00

3. **Telefone**: `data-mask-type-value="phone"`
   - Formatos: (00) 00000-0000 ou (00) 0000-0000

4. **Customizado**: `data-mask-type-value="custom"`
   - Permite definir opções personalizadas via `data-mask-options-value`

#### Exemplo Completo

```erb
<%= form_with model: @professional, local: true do |f| %>
  <div class="form-group">
    <label>CPF</label>
    <div data-controller="mask" data-mask-type-value="cpf">
      <%= f.text_field :cpf, 
          class: "form-control",
          data: { mask_target: "input" } %>
    </div>
  </div>

  <div class="form-group">
    <label>Telefone</label>
    <div data-controller="mask" data-mask-type-value="phone">
      <%= f.text_field :phone, 
          class: "form-control",
          data: { mask_target: "input" } %>
    </div>
  </div>

  <div class="form-group">
    <label>CNPJ</label>
    <div data-controller="mask" data-mask-type-value="cnpj">
      <%= f.text_field :cnpj, 
          class: "form-control",
          data: { mask_target: "input" } %>
    </div>
  </div>
<% end %>
```

#### Eventos

O controller dispara o evento `masked` quando o valor é aceito:

```javascript
document.addEventListener('masked', (event) => {
  console.log('Valor mascarado:', event.detail.value)
})
```

#### Métodos Disponíveis

- `getValue()`: Retorna o valor mascarado
- `getUnmaskedValue()`: Retorna o valor sem máscara

#### Configuração Customizada

Para máscaras personalizadas, use o tipo "custom" e defina as opções:

```erb
<div data-controller="mask" 
     data-mask-type-value="custom"
     data-mask-options-value='{"mask": "0000-0000", "lazy": false}'>
  <%= f.text_field :codigo, 
      data: { mask_target: "input" } %>
</div>
```

# Catálogo de Componentes (ViewComponent)

## Botões (`Ui::ButtonComponent`)
Exemplos:
- Primário: `render Ui::ButtonComponent.new(label: "Salvar")`
- Secundário: `render Ui::ButtonComponent.new(label: "Cancelar", variant: :secondary)`
- Outline: `render Ui::ButtonComponent.new(label: "Ação", variant: :outline)`
- Link: `render Ui::ButtonComponent.new(label: "Ver mais", variant: :link)`
- Com ícone: `render Ui::ButtonComponent.new(label: "Novo", icon: "bi-plus")`

## Alertas (`Ui::AlertComponent`)
- `render Ui::AlertComponent.new(kind: :success, title: "Sucesso") { "Registro salvo" }`
- Kinds: `:info`, `:success`, `:warning`, `:danger`

## Badges (`Ui::BadgeComponent`)
- `render Ui::BadgeComponent.new(label: "Novo", tone: :brand)`
- Tons: `:brand`, `:success`, `:warning`, `:danger`, `:gray`

## Card (`Ui::CardComponent`)
- `render Ui::CardComponent.new(title: "Título") { "Conteúdo" }`
- Ações: `render Ui::CardComponent.new(title: "Título", actions: (render Ui::ButtonComponent.new(label: "Ação", variant: :secondary)))`

## Tabela PRO (`Ui::ProTableComponent`)
- `render Ui::ProTableComponent.new(columns: [ {key: :id, label: "ID"}, {key: :nome, label: "Nome"} ], rows: [{id: 1, nome: "Alice"}], actions: ->(row){ render Ui::ButtonComponent.new(label: "Editar", variant: :ghost) })`

## Campo de Formulário (`Ui::FormFieldComponent`)
- `render Ui::FormFieldComponent.new(label: "Nome", hint: "Opcional") { text_field_tag :nome, nil, class: "ta-input w-full" }`
