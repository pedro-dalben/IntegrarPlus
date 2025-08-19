# Sidebar Implementation - Baseada no TailAdmin

## Visão Geral

A nova sidebar foi completamente refatorada baseada no design e funcionalidades do TailAdmin, oferecendo uma experiência moderna e responsiva com integração completa com Stimulus.

## Características Principais

### 🎨 Design Moderno
- Baseado no TailAdmin com estilos profissionais
- Suporte completo a dark mode
- Animações suaves e transições elegantes
- Layout responsivo para mobile e desktop

### ⚡ Funcionalidades Avançadas
- Toggle de colapso da sidebar
- Estado persistente no localStorage
- Integração com header via eventos customizados
- Suporte a badges e ícones
- Menu dropdowns (preparado para futuras implementações)

### 🔧 Integração Stimulus
- Controller dedicado para sidebar (`sidebar_controller.js`)
- Controller atualizado para header (`header_component_controller.js`)
- Comunicação via eventos customizados
- Gerenciamento de estado reativo

## Estrutura dos Arquivos

### Componentes
```
app/components/ui/sidebar_component.rb          # Lógica do componente
app/components/ui/sidebar_component.html.erb    # Template da sidebar
app/components/ui/header_component.html.erb     # Header atualizado
```

### Controllers Stimulus
```
app/frontend/javascript/controllers/sidebar_controller.js
app/frontend/javascript/controllers/header_component_controller.js
```

### Estilos
```
app/frontend/styles/sidebar.css                 # Estilos específicos da sidebar
app/frontend/styles/application.css             # Import dos estilos
```

## Como Usar

### 1. Renderizar a Sidebar
```erb
<%= render Ui::SidebarComponent.new(current_path: request.path) %>
```

### 2. Configurar Menu Items
No componente Ruby, adicione itens ao método `menu_items`:

```ruby
def menu_items
  [
    {
      title: "Dashboard",
      path: "/admin/dashboard",
      icon: dashboard_icon,
      active: current_path&.start_with?("/admin/dashboard"),
      badge: nil  # ou "New", "Pro", etc.
    },
    # ... mais itens
  ]
end
```

### 3. Adicionar Ícones
Crie métodos para os ícones SVG:

```ruby
def dashboard_icon
  '<svg class="shrink-0 size-4" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9,22 9,12 15,12 15,22"/></svg>'.html_safe
end
```

## Funcionalidades do Controller Stimulus

### Sidebar Controller

#### Métodos Principais
- `toggle()` - Alterna colapso da sidebar
- `toggleDropdown(event)` - Gerencia dropdowns (futuro)
- `selectMenuItem(event)` - Seleciona item do menu
- `handleResize()` - Gerencia responsividade
- `closeMobile()` / `openMobile()` - Controles mobile

#### Estados Persistidos
- `collapsed` - Estado de colapso da sidebar
- `selected` - Item de menu selecionado

### Header Controller

#### Integração com Sidebar
- `toggleSidebar()` - Dispara evento para sidebar
- `updatePosition()` - Ajusta posição baseada no estado da sidebar
- `toggleDarkMode()` - Alterna modo escuro

## Estilos CSS

### Classes Principais
```css
.sidebar                    # Container principal
.sidebar-collapsed         # Estado colapsado
.menu-item                 # Item do menu
.menu-item-active          # Item ativo
.menu-item-icon            # Ícone do item
.menu-item-text            # Texto do item
.menu-item-badge           # Badge do item
```

### Responsividade
- **Mobile (< 1280px)**: Sidebar off-canvas com overlay
- **Desktop (≥ 1280px)**: Sidebar sempre visível
- **Toggle**: Botão hamburger no header

### Dark Mode
- Suporte completo via classes `.dark`
- Cores adaptadas para tema escuro
- Transições suaves entre temas

## Eventos Customizados

### `sidebar-toggle`
Disparado pelo header para alternar sidebar:
```javascript
this.dispatch("sidebar-toggle", { detail: { collapsed: this.collapsedValue } })
```

### `sidebar-toggle` (document)
Escutado pelo header para ajustar posição:
```javascript
document.addEventListener('sidebar-toggle', this.handleSidebarToggle)
```

## Configuração

### Largura da Sidebar
```erb
data-header-component-sidebar-width-value="290"
```

### Estado Inicial
```erb
data-sidebar-collapsed-value="false"
data-sidebar-selected-value=""
```

## Melhorias Futuras

### Dropdowns
A estrutura está preparada para implementar dropdowns:
```erb
<div data-dropdown="menuName" class="hidden">
  <ul class="menu-dropdown">
    <li><a href="#" class="menu-dropdown-item">Submenu</a></li>
  </ul>
</div>
```

### Badges Dinâmicos
```ruby
{
  title: "Notificações",
  badge: "3",  # Número dinâmico
  badge_type: "notification"  # Tipo de badge
}
```

### Animações Avançadas
- Transições mais elaboradas
- Micro-interações
- Feedback visual aprimorado

## Troubleshooting

### Sidebar não aparece
1. Verifique se o CSS está importado
2. Confirme se o controller Stimulus está registrado
3. Verifique se não há conflitos de z-index

### Toggle não funciona
1. Verifique se o evento está sendo disparado
2. Confirme se o controller está conectado
3. Verifique o console para erros JavaScript

### Estilos não aplicados
1. Verifique se `sidebar.css` está importado
2. Confirme se as classes Tailwind estão disponíveis
3. Verifique se não há CSS conflitante

## Performance

### Otimizações Implementadas
- Event listeners com cleanup adequado
- Estado persistido no localStorage
- Transições CSS otimizadas
- Lazy loading de funcionalidades

### Monitoramento
- Console logs para debugging
- Eventos customizados para tracking
- Estados visíveis no DOM

## Acessibilidade

### Recursos Implementados
- Navegação por teclado
- Screen reader support
- Focus management
- ARIA labels apropriados

### Melhorias Sugeridas
- Skip links
- Keyboard shortcuts
- Voice navigation
- High contrast mode
