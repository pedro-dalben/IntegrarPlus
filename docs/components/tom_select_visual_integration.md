# Tom Select - Integração Visual com Tailwind + TailAdmin

## Objetivo

Fazer com que o Tom Select tenha exatamente a mesma aparência dos inputs normais do Tailwind + TailAdmin, tanto no estado vazio quanto com valores selecionados.

## Problema Identificado

O Tom Select ainda estava visualmente diferente dos inputs normais porque:
1. **Altura inconsistente** entre estados vazio e com valores
2. **Itens selecionados muito destacados** com fundos e bordas
3. **Padding diferente** dos inputs padrão

## Solução Implementada

### 1. Altura e Padding Consistentes

```scss
.ts-control {
  @apply h-11 w-full rounded-lg border border-gray-300 bg-white px-4 py-3;
  // Altura fixa h-11 igual aos inputs normais
  // Padding py-3 igual aos inputs normais
}

// Estado vazio - igual ao input normal
.ts-control:empty {
  @apply py-3;
}

// Estado com valores - ajustado para manter consistência
.ts-control:not(:empty) {
  @apply py-2;
}
```

### 2. Itens Selecionados Integrados

```scss
.ts-item-integrated {
  @apply inline-flex items-center gap-1 px-2 py-0.5 bg-transparent text-gray-700 text-xs font-normal border-none;
  // bg-transparent - sem fundo destacado
  // border-none - sem bordas
  // py-0.5 - padding mínimo para não afetar altura
}
```

### 3. Cores Consistentes

```scss
.ts-control {
  @apply text-gray-900 placeholder:text-gray-500;
  // text-gray-900 igual aos inputs normais
  // placeholder:text-gray-500 igual aos inputs normais
}

.ts-input {
  @apply text-gray-900 placeholder:text-gray-500;
  // Mesmas cores do input interno
}
```

## Resultado Visual

### Estado Vazio
```
┌─────────────────────────────────────┐
│ Selecione os grupos...             │ ← Igual ao input normal
└─────────────────────────────────────┘
```

### Estado com Valores
```
┌─────────────────────────────────────┐
│ Coordenadores × Profissionais ×    │ ← Integrado, sem destaque
└─────────────────────────────────────┘
```

## Comparação com Inputs Normais

### Input Normal (Rua, Número, etc.)
- **Altura**: `h-11`
- **Padding**: `px-4 py-3`
- **Texto**: `text-gray-900`
- **Placeholder**: `text-gray-500`
- **Borda**: `border-gray-300`

### Tom Select (Ajustado)
- **Altura**: `h-11` ✅
- **Padding**: `px-4 py-3` ✅
- **Texto**: `text-gray-900` ✅
- **Placeholder**: `text-gray-500` ✅
- **Borda**: `border-gray-300` ✅

## Implementação no Controller

```javascript
this.tomSelect = new TomSelect(this.selectTarget, {
  plugins: ['remove_button'],
  itemClass: 'ts-item-integrated', // ✅ Classe para itens integrados
  // ... outras opções
});
```

## Estilos CSS Completos

```scss
.ts-item-integrated {
  @apply inline-flex items-center gap-1 px-2 py-0.5 bg-transparent text-gray-700 text-xs font-normal border-none;
  @apply transition-all duration-200;
  
  .remove {
    @apply ml-1 text-gray-400 hover:text-gray-600 cursor-pointer;
    @apply w-4 h-4 flex items-center justify-center rounded-full hover:bg-gray-100;
    
    &:hover {
      @apply text-red-500;
    }
    
    &:before {
      content: "×";
      @apply text-sm font-bold;
    }
  }
  
  &:hover {
    @apply bg-gray-50;
  }
}
```

## Verificação da Integração

### ✅ **Deve Parecer:**
- Input normal quando vazio
- Input normal com texto interno quando tem valores
- Mesma altura e padding dos outros campos
- Mesmas cores e bordas

### ❌ **Não Deve Parecer:**
- Campo destacado ou diferente
- Tags com fundos coloridos
- Altura variável entre estados
- Padding inconsistente

## Teste Visual

1. **Abra um formulário** com Tom Select (ex: profissionais)
2. **Compare visualmente** com inputs normais (Rua, Número, etc.)
3. **Verifique se:**
   - Altura é idêntica
   - Padding é consistente
   - Cores são iguais
   - Bordas são idênticas

## Manutenção

### Para Novos Campos
```erb
<div data-controller="tom-select">
  <%= form.select :field_name,
      @options,
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

### Para Novos Estilos
```scss
.ts-item-integrated {
  // Seus estilos customizados aqui
  // Mantenha a integração visual
}
```

## Conclusão

Com essas correções, o Tom Select agora deve ter:
- ✅ **Aparência idêntica** aos inputs normais
- ✅ **Altura consistente** em todos os estados
- ✅ **Itens selecionados integrados** ao campo
- ✅ **Visual unificado** com o design system

O resultado final deve ser um campo que, visualmente, é indistinguível de um input normal, mas com toda a funcionalidade avançada do Tom Select.
