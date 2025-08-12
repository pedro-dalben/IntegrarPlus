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
