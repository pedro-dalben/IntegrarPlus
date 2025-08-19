# Dropdown Controller - Stimulus

Controller genérico para dropdowns que substitui o Alpine.js.

## Uso Básico

```html
<div data-controller="dropdown">
  <!-- Botão do dropdown -->
  <button 
    data-action="click->dropdown#toggle"
    data-dropdown-target="button"
    aria-expanded="false"
    aria-label="Abrir menu"
  >
    Menu
  </button>

  <!-- Painel do dropdown -->
  <div 
    data-dropdown-target="panel"
    class="hidden"
  >
    <!-- Conteúdo do dropdown -->
    <a href="#">Item 1</a>
    <a href="#">Item 2</a>
  </div>
</div>
```

## Targets Disponíveis

- `panel`: O painel que será mostrado/escondido
- `button`: O botão que controla o dropdown (opcional)
- `indicator`: Indicador visual (ex: badge de notificação)
- `arrow`: Seta que rotaciona quando dropdown abre/fecha

## Actions

- `click->dropdown#toggle`: Alterna o dropdown
- `keydown->dropdown#handleKeydown`: Navegação por teclado (Enter, Espaço, Escape)

## Funcionalidades

### ✅ Abrir/Fechar
- Click no botão alterna o estado
- Click fora fecha automaticamente
- Fecha em `turbo:load`

### ✅ Acessibilidade
- `aria-expanded` atualizado automaticamente
- Navegação por teclado (Enter, Espaço, Escape)
- Suporte a `role="button"` e `tabindex`

### ✅ Indicadores Visuais
- Esconde indicador quando dropdown abre
- Rotaciona seta quando dropdown abre/fecha

### ✅ Transições
- Animações suaves com CSS
- Transform e opacity para efeito visual

## Exemplos de Implementação

### Dropdown de Notificações
```html
<div data-controller="dropdown">
  <button 
    data-action="click->dropdown#toggle"
    data-dropdown-target="button"
    aria-expanded="false"
    aria-label="Notificações"
  >
    <span data-dropdown-target="indicator" class="notification-badge">3</span>
    🔔
  </button>

  <div data-dropdown-target="panel" class="hidden">
    <!-- Lista de notificações -->
  </div>
</div>
```

### Dropdown do Usuário
```html
<div data-controller="dropdown">
  <a 
    href="#"
    role="button"
    tabindex="0"
    data-action="click->dropdown#toggle keydown->dropdown#handleKeydown"
    aria-expanded="false"
    aria-label="Menu do usuário"
  >
    <span>Nome do Usuário</span>
    <svg data-dropdown-target="arrow">▼</svg>
  </a>

  <div data-dropdown-target="panel" class="hidden">
    <!-- Menu do usuário -->
  </div>
</div>
```

### Dropdown Simples
```html
<div data-controller="dropdown">
  <button data-action="click->dropdown#toggle">
    Opções
  </button>

  <div data-dropdown-target="panel" class="hidden">
    <a href="#">Editar</a>
    <a href="#">Excluir</a>
  </div>
</div>
```

## CSS Recomendado

```css
[data-dropdown-target="panel"] {
  transition: opacity 0.3s ease-in-out, transform 0.3s ease-in-out;
  transform-origin: top right;
}

[data-dropdown-target="panel"].hidden {
  opacity: 0;
  transform: scale(0.95);
  pointer-events: none;
}

[data-dropdown-target="panel"]:not(.hidden) {
  opacity: 1;
  transform: scale(1);
  pointer-events: auto;
}
```

## Vantagens

1. **Reutilizável**: Um controller para todos os dropdowns
2. **Acessível**: Suporte completo a ARIA e navegação por teclado
3. **Performático**: Sem dependências externas
4. **Flexível**: Suporta diferentes tipos de dropdowns
5. **Manutenível**: Código centralizado e bem documentado
