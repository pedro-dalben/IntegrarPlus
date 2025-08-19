# Controllers Stimulus - Sidebar Dinâmica

Implementação de controllers Stimulus para tornar a sidebar dinâmica e Turbo-safe.

## 1. Header Controller

**Arquivo**: `app/frontend/javascript/controllers/header_controller.js`

### Responsabilidades
- ✅ Botão hambúrguer → abre/fecha sidebar no mobile
- ✅ Dark mode com persistência
- ✅ Atalhos de busca (opcional)

### Funcionalidades

#### `toggleSidebar()`
- Alterna estado da sidebar
- Persiste em localStorage
- Emite evento `ui:sidebar` para sincronização

#### `toggleDark()`
- Alterna modo escuro
- Persiste em localStorage
- Aplica classe `dark` no `documentElement`

#### `focusSearch()`
- Foca no campo de busca
- Suporte a atalhos de teclado

### Uso no HTML
```html
<header data-controller="header" class="sticky top-0 z-[9999] bg-white border-b dark:bg-gray-900 dark:border-gray-800">
  <div class="flex items-center justify-between px-4 py-3">
    <button class="xl:hidden btn" data-action="click->header#toggleSidebar">☰</button>
    <!-- ... resto do header ... -->
    <button class="btn" data-action="click->header#toggleDark">🌙</button>
  </div>
</header>
```

## 2. Sidebar Controller

**Arquivo**: `app/frontend/javascript/controllers/sidebar_controller.js`

### Responsabilidades
- ✅ Mostrar/ocultar em mobile com classes de transição
- ✅ Ficar sempre visível em desktop (≥ xl)
- ✅ Fechar "ao clicar fora" apenas em mobile

### Funcionalidades

#### `connect()`
- Aplica estado inicial salvo
- Escuta eventos `ui:sidebar` para sincronização
- Fecha sidebar em mobile ao navegar (`turbo:load`)

#### `outside(e)`
- Detecta clicks fora da sidebar
- Só funciona em mobile (< 1280px)
- Fecha sidebar automaticamente

#### `apply(open)`
- Aplica estado visual da sidebar
- Persiste em localStorage
- Usa classes `-translate-x-full` e `translate-x-0`

### Uso no HTML
```html
<aside
  data-controller="sidebar"
  data-action="click@window->sidebar#outside"
  class="
    fixed inset-y-0 left-0 z-[9998] w-72 transform border-r bg-white transition-transform duration-300
    dark:bg-black dark:border-gray-800
    -translate-x-full
    xl:static xl:translate-x-0
  "
>
  <!-- conteúdo sidebar -->
</aside>
```

## 3. Layout Admin

**Arquivo**: `app/views/layouts/admin.html.erb`

### Estrutura
```erb
<div class="flex min-h-[calc(100vh-56px)]">
  <!-- Drawer mobile + fixa desktop -->
  <aside
    data-controller="sidebar"
    data-action="click@window->sidebar#outside"
    class="
      fixed inset-y-0 left-0 z-[9998] w-72 transform border-r bg-white transition-transform duration-300
      dark:bg-black dark:border-gray-800
      -translate-x-full
      xl:static xl:translate-x-0
    "
  >
    <%= render Ui::SidebarComponent.new(current_path: request.path) %>
  </aside>

  <main class="flex-1 p-4 xl:p-6 xl:ml-0">
    <!-- conteúdo -->
  </main>
</div>
```

## 4. Comportamento

### Desktop (≥ xl)
- Sidebar sempre visível (`xl:static xl:translate-x-0`)
- Content ocupa espaço restante (`flex-1`)
- Sem overlay ou click fora

### Mobile (< xl)
- Sidebar oculta por padrão (`-translate-x-full`)
- Botão hambúrguer abre/fecha
- Click fora fecha automaticamente
- Transições suaves

### Turbo-safe
- Estado persistido em localStorage
- Sincronização via eventos customizados
- Fecha em mobile ao navegar

## 5. Eventos

### `ui:sidebar`
```javascript
window.dispatchEvent(new CustomEvent("ui:sidebar", { 
  detail: { open: true/false } 
}));
```

### `turbo:load`
- Fecha sidebar em mobile
- Mantém estado em desktop

## 6. Vantagens

1. **Turbo-safe**: Funciona com navegação Turbo
2. **Responsivo**: Comportamento adaptativo
3. **Persistente**: Estado salvo em localStorage
4. **Acessível**: Suporte a navegação por teclado
5. **Performático**: Transições CSS suaves
6. **Manutenível**: Código limpo e bem estruturado

## 7. Uso

1. **Header**: Contém botão hambúrguer e dark mode
2. **Sidebar**: Gerencia visibilidade e interações
3. **Layout**: Estrutura responsiva
4. **Sincronização**: Eventos entre controllers

O sistema garante que a sidebar funcione corretamente em todos os dispositivos e seja compatível com Turbo Drive.
