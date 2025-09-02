# Tom Select - Guia de Uso

## Visão Geral

O Tom Select é um componente de select avançado que substitui os selects padrão do HTML, oferecendo funcionalidades como busca, seleção múltipla, tags removíveis e um design consistente com o TailAdmin.

## Implementação

### Controller Stimulus

O componente é controlado pelo `TomSelectController` que:
- Esconde automaticamente o select original
- Inicializa o Tom Select com as opções configuradas
- Gerencia o ciclo de vida do componente

### Estilos CSS

Os estilos estão definidos em `app/frontend/stylesheets/components/_tom_select.scss` e incluem:
- Design consistente com o TailAdmin
- Suporte a tema claro/escuro
- Animações suaves
- Estados de foco, erro e sucesso

## Como Usar

### Uso Básico

```erb
<div data-controller="tom-select">
  <%= form.select :field_name,
      options_for_select(@options),
      { prompt: "Selecione..." },
      {
        multiple: true,
        data: {
          tom_select_target: "select",
          tom_select_options_value: {
            plugins: ['remove_button'],
            placeholder: "Selecione...",
            maxItems: nil,
            create: false
          }.to_json
        }
      } %>
</div>
```

### Configurações Disponíveis

#### Plugins
- `remove_button`: Adiciona botão X para remover itens selecionados
- `dropdown_input`: Permite busca no dropdown
- `no_backspace_delete`: Desabilita remoção com backspace

#### Opções
- `placeholder`: Texto exibido quando nenhum item está selecionado
- `maxItems`: Número máximo de itens selecionáveis (nil = ilimitado)
- `create`: Permite criar novos itens (true/false)
- `searchField`: Campos para busca (padrão: ['text'])

### Exemplo com Seleção Múltipla

```erb
<div data-controller="tom-select">
  <%= form.select :group_ids,
      @groups.map { |g| [g.name, g.id] },
      { prompt: "Selecione os grupos..." },
      {
        multiple: true,
        data: {
          tom_select_target: "select",
          tom_select_options_value: {
            plugins: ['remove_button'],
            placeholder: "Selecione os grupos...",
            maxItems: nil,
            create: false
          }.to_json
        }
      } %>
</div>
```

### Exemplo com Dependência

```erb
<div data-controller="tom-select dependent-specializations"
     data-dependent-specializations-endpoint-value="/admin/specializations.json">
  
  <!-- Select de Especialidades -->
  <%= form.select :speciality_ids,
      @specialities.map { |s| [s.name, s.id] },
      { prompt: "Selecione especialidades..." },
      {
        multiple: true,
        data: {
          tom_select_target: "select",
          dependent_specializations_target: "specialitySelect",
          action: "change->dependent-specializations#specialityChanged",
          tom_select_options_value: {
            plugins: ['remove_button'],
            placeholder: "Selecione especialidades...",
            maxItems: nil,
            create: false
          }.to_json
        }
      } %>

  <!-- Select de Especializações -->
  <%= form.select :specialization_ids,
      [],
      { prompt: "Selecione especializações..." },
      {
        multiple: true,
        data: {
          tom_select_target: "select",
          dependent_specializations_target: "specializationSelect",
          tom_select_options_value: {
            plugins: ['remove_button'],
            placeholder: "Selecione especializações...",
            maxItems: nil,
            create: false
          }.to_json
        }
      } %>
</div>
```

## Regras Importantes

### 1. Não Adicionar Classes CSS ao Select
O select original deve ter apenas as configurações necessárias. **NÃO** adicione classes de estilo como:
- `border`, `rounded-lg`, `px-4`, `py-3`
- `focus:ring-2`, `focus:border-blue-500`
- `bg-white`, `text-gray-900`

### 2. Sempre Usar o Controller
```erb
<!-- ✅ Correto -->
<div data-controller="tom-select">
  <%= form.select :field, options, {}, { data: { tom_select_target: "select" } } %>
</div>

<!-- ❌ Incorreto -->
<%= form.select :field, options, {}, { class: "border rounded-lg..." } %>
```

### 3. Configurar Placeholder
Use o atributo `prompt` no select e configure o `placeholder` nas opções do Tom Select:

```erb
{ prompt: "Selecione..." }  # Para o select original
{ placeholder: "Selecione..." }  # Para o Tom Select
```

## Solução de Problemas

### Select Aparecendo Duplo
Se você ver duas bordas ou o select original aparecendo:
1. Verifique se o controller `tom-select` está sendo usado
2. Remova todas as classes CSS do select
3. Certifique-se de que o `data-tom-select-target="select"` está configurado

### Estilos Não Aplicados
Se os estilos não estão sendo aplicados:
1. Verifique se o arquivo `_tom_select.scss` está sendo importado
2. Confirme que o controller está funcionando
3. Verifique o console do navegador para erros JavaScript

### Funcionalidade de Busca Não Funciona
Para habilitar a busca:
```erb
tom_select_options_value: {
  plugins: ['remove_button', 'dropdown_input'],
  placeholder: "Selecione...",
  maxItems: nil,
  create: false
}.to_json
```

## Exemplos de Implementação

### Formulário de Profissional
```erb
<!-- Grupos -->
<div data-controller="tom-select">
  <%= form.select :group_ids,
      @groups.map { |g| [g.name, g.id] },
      { prompt: "Selecione os grupos..." },
      {
        multiple: true,
        data: {
          tom_select_target: "select",
          tom_select_options_value: {
            plugins: ['remove_button'],
            placeholder: "Selecione os grupos...",
            maxItems: nil,
            create: false
          }.to_json
        }
      } %>
</div>
```

### Formulário de Especialização
```erb
<!-- Especialidades -->
<div data-controller="tom-select">
  <%= form.select :speciality_ids,
      @specialities.map { |s| [s.name, s.id] },
      { prompt: "Selecione as especialidades..." },
      {
        multiple: true,
        data: {
          tom_select_target: "select",
          tom_select_options_value: {
            plugins: ['remove_button'],
            placeholder: "Selecione as especialidades...",
            maxItems: nil,
            create: false
          }.to_json
        }
      } %>
</div>
```

## Manutenção

### Adicionar Novos Estilos
Para customizar estilos, edite `app/frontend/stylesheets/components/_tom_select.scss`:

```scss
.ts-wrapper {
  .ts-control {
    @apply min-h-11 w-full rounded-lg border border-gray-300;
    // Seus estilos customizados aqui
  }
}
```

### Novos Plugins
Para adicionar novos plugins, modifique o controller:

```javascript
this.tomSelect = new TomSelect(this.selectTarget, {
  plugins: ['remove_button', 'seu_plugin'],
  // outras opções...
});
```

## Conclusão

O Tom Select oferece uma experiência de usuário superior aos selects padrão, com design consistente e funcionalidades avançadas. Seguindo estas diretrizes, você garantirá que todos os selects tenham aparência uniforme e funcionem corretamente em todo o projeto.
