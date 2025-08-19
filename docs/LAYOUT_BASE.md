# Layout Base - Tailwind CSS

Layout fixo de referência usando apenas Tailwind CSS, sem dependências de JavaScript.

## Estrutura do Layout

### Desktop (≥ xl)
- **Container principal**: `flex h-screen overflow-hidden`
- **Sidebar**: Largura fixa (`w-72` = 18rem) + `xl:static`
- **Content**: Ocupa o resto (`flex-1`) com header sticky

### Mobile (< xl)
- **Sidebar**: Drawer oculto (`-translate-x-full`) que entra com `translate-x-0`
- **Content**: Ocupa 100% (`w-full`) com header sticky

## HTML/ERB Base

```erb
<body class="bg-gray-50 dark:bg-gray-900">
  <!-- Layout Container -->
  <div class="flex h-screen overflow-hidden">
    
    <!-- Sidebar (fixa em desktop, drawer em mobile) -->
    <aside
      data-controller="sidebar"
      data-action="click@window->sidebar#outside"
      class="sidebar fixed top-0 left-0 z-50 flex h-screen w-72 flex-col overflow-y-auto border-r border-gray-200 bg-white transition-transform duration-300 xl:static xl:translate-x-0 dark:border-gray-800 dark:bg-gray-900 -translate-x-full"
    >
      <!-- conteúdo da sidebar -->
    </aside>

    <!-- Content Area -->
    <div class="flex flex-1 flex-col overflow-hidden">
      
      <!-- Header -->
      <header class="sticky top-0 z-40 bg-white border-b border-gray-200 dark:bg-gray-900 dark:border-gray-800">
        <!-- conteúdo do header -->
      </header>

      <!-- Main Content -->
      <main id="main-content" class="flex-1 overflow-y-auto">
        <div class="mx-auto max-w-7xl p-4 sm:p-6 lg:p-8">
          <!-- conteúdo da página -->
        </div>
      </main>
    </div>

    <!-- Mobile Overlay -->
    <div
      data-sidebar-target="overlay"
      class="fixed inset-0 z-40 bg-gray-900/50 hidden xl:hidden"
    ></div>
  </div>
</body>
```

## Características

### ✅ **Responsivo**
- Desktop: Sidebar fixa à esquerda
- Mobile: Sidebar como drawer (oculta por padrão)

### ✅ **Sem JavaScript**
- Layout funciona apenas com CSS
- Classes condicionais do Tailwind (`xl:`, `hidden`, etc.)

### ✅ **Acessibilidade**
- Skip link para navegação por teclado
- Estrutura semântica (`header`, `main`, `aside`)
- IDs para navegação (`main-content`)

### ✅ **Performance**
- Sem dependências externas
- CSS puro para layout
- Transições suaves com Tailwind

### ✅ **Dark Mode**
- Suporte completo a modo escuro
- Classes `dark:` do Tailwind

## Classes Principais

### Container
- `flex h-screen overflow-hidden`: Container principal
- `flex flex-1 flex-col overflow-hidden`: Área de conteúdo

### Sidebar
- `fixed top-0 left-0 z-50`: Posicionamento mobile
- `xl:static`: Posicionamento desktop
- `w-72`: Largura fixa (18rem)
- `-translate-x-full`: Oculto em mobile
- `xl:translate-x-0`: Visível em desktop

### Header
- `sticky top-0 z-40`: Header fixo
- `border-b`: Borda inferior

### Content
- `flex-1 overflow-y-auto`: Ocupa espaço restante
- `max-w-7xl`: Largura máxima do conteúdo
- `p-4 sm:p-6 lg:p-8`: Padding responsivo

### Overlay
- `fixed inset-0 z-40`: Cobre toda a tela
- `hidden xl:hidden`: Oculto em desktop

## Vantagens

1. **Simplicidade**: Apenas Tailwind CSS
2. **Performance**: Sem JavaScript para layout
3. **Responsivo**: Funciona em todos os dispositivos
4. **Acessível**: Estrutura semântica
5. **Manutenível**: Código limpo e organizado
6. **Flexível**: Fácil de customizar

## Uso

Este layout serve como base para todas as páginas administrativas, garantindo consistência visual e funcional em toda a aplicação.
