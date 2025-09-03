# Tom Select - Melhores Práticas

## Problema Resolvido

O problema de "input dentro do outro" foi causado por:
1. **Classes CSS conflitantes** no select original
2. **Estilos duplicados** entre o select e o Tom Select
3. **Falta de ocultação** do select original

## Solução Implementada

### 1. Controller Atualizado
```javascript
// app/frontend/javascript/controllers/tom_select_controller.js
connect() {
  this.hideOriginalSelect(); // ✅ Esconde o select original
  // ... resto do código
}

hideOriginalSelect() {
  if (this.hasSelectTarget) {
    this.selectTarget.style.display = 'none'; // ✅ Completamente oculto
  }
}
```

### 2. Estilos Limpos
```scss
// app/frontend/stylesheets/components/_tom_select.scss
select[data-tom-select-target="select"] {
  @apply hidden; // ✅ Regra global para esconder
}

.ts-wrapper .ts-control {
  @apply min-h-11 w-full rounded-lg border border-gray-300; // ✅ Estilos únicos
}
```

### 3. Formulários Limpos
```erb
<!-- ✅ CORRETO: Sem classes CSS conflitantes -->
<div data-controller="tom-select">
  <%= form.select :group_ids,
      @groups.map { |g| [g.name, g.id] },
      { prompt: "Selecione os grupos..." },
      {
        multiple: true,
        data: {
          tom_select_target: "select",
          tom_select_options_value: { ... }.to_json
        }
      } %>
</div>

<!-- ❌ INCORRETO: Com classes CSS conflitantes -->
<%= form.select :group_ids,
    @groups.map { |g| [g.name, g.id] },
    { prompt: "Selecione os grupos..." },
    {
      class: "border rounded-lg px-4 py-3...", # ❌ Causa conflito
      multiple: true,
      data: { ... }
    } %>
```

## Estilos dos Itens Selecionados

### Estilo Padrão (Mais Visível)
```scss
.item {
  @apply bg-gray-100 text-gray-700 border-gray-200;
  @apply font-medium;
}
```

### Estilo Sutil (Mais Integrado)
```scss
.ts-item-subtle {
  @apply bg-gray-50 text-gray-600 border-gray-200;
  @apply font-normal; // Menos chamativo
}
```

## Checklist de Implementação

### ✅ **Antes de Usar Tom Select:**
- [ ] Remover todas as classes CSS do select original
- [ ] Usar apenas `data-tom-select-target="select"`
- [ ] Configurar `data-controller="tom-select"`
- [ ] Definir opções via `tom_select_options_value`

### ✅ **Verificar Resultado:**
- [ ] Select original está oculto
- [ ] Tom Select aparece com borda única
- [ ] Itens selecionados têm aparência integrada
- [ ] Sem bordas duplas ou conflitos visuais

## Exemplos de Uso Correto

### Seleção Múltipla Simples
```erb
<div data-controller="tom-select">
  <%= form.select :tags,
      @available_tags,
      { prompt: "Selecione tags..." },
      {
        multiple: true,
        data: {
          tom_select_target: "select",
          tom_select_options_value: {
            plugins: ['remove_button'],
            placeholder: "Selecione tags...",
            maxItems: 5,
            create: false
          }.to_json
        }
      } %>
</div>
```

### Seleção com Dependência
```erb
<div data-controller="tom-select dependent-selects">
  <!-- Select principal -->
  <%= form.select :category_id,
      @categories,
      { prompt: "Selecione categoria..." },
      {
        data: {
          tom_select_target: "select",
          dependent_selects_target: "primary",
          action: "change->dependent-selects#primaryChanged"
        }
      } %>
  
  <!-- Select dependente -->
  <%= form.select :subcategory_id,
      [],
      { prompt: "Selecione subcategoria..." },
      {
        data: {
          tom_select_target: "select",
          dependent_selects_target: "secondary"
        }
      } %>
</div>
```

## Solução de Problemas

### Problema: "Input dentro do outro"
**Causa:** Classes CSS conflitantes no select original
**Solução:** Remover todas as classes de estilo

### Problema: Bordas duplas
**Causa:** Select original ainda visível
**Solução:** Verificar se `data-tom-select-target="select"` está configurado

### Problema: Estilos não aplicados
**Causa:** Arquivo CSS não importado ou controller não funcionando
**Solução:** Verificar import em `application.tailwind.css` e console do navegador

## Manutenção

### Adicionar Novos Estilos
```scss
// app/frontend/stylesheets/components/_tom_select.scss
.ts-wrapper {
  .ts-control {
    // Seus estilos customizados aqui
  }
  
  .item {
    // Estilos para itens selecionados
  }
}
```

### Novos Plugins
```javascript
// app/frontend/javascript/controllers/tom_select_controller.js
this.tomSelect = new TomSelect(this.selectTarget, {
  plugins: ['remove_button', 'seu_plugin'],
  // outras opções...
});
```

## Conclusão

Seguindo estas práticas, o Tom Select terá:
- ✅ Layout limpo e profissional
- ✅ Aparência consistente com inputs normais
- ✅ Sem conflitos visuais
- ✅ Funcionalidade completa de seleção múltipla
- ✅ Integração perfeita com o design system

**Lembre-se:** O segredo é manter o select original limpo e deixar o Tom Select cuidar de toda a estilização.
