# Sidebar Helpers - Marcação de Menu Ativo

Helpers Rails para aplicar classes ativas e controlar grupos colapsáveis com base na rota/página atual.

## 1. Helpers Disponíveis

### `sidebar_menu_item_active?(path)`
Verifica se um item de menu está ativo.

```ruby
sidebar_menu_item_active?('/admin/dashboard') # true se estiver na página dashboard
```

### `sidebar_group_active?(group_paths)`
Verifica se um grupo está ativo (qualquer item do grupo).

```ruby
sidebar_group_active?(['/admin/professionals', '/admin/professionals/new']) # true se estiver em qualquer página de profissionais
```

### `sidebar_menu_item_classes(path, base_classes)`
Retorna classes CSS para item de menu com estado ativo.

```ruby
sidebar_menu_item_classes('/admin/dashboard', 'menu-item group')
# Retorna: "menu-item group" ou "menu-item group menu-item-active"
```

### `sidebar_group_classes(group_paths, base_classes)`
Retorna classes CSS para grupo com estado ativo.

```ruby
sidebar_group_classes(['/admin/professionals'], 'menu-item group')
# Retorna: "menu-item group" ou "menu-item group menu-item-active"
```

### `sidebar_dropdown_classes(group_paths, base_classes)`
Retorna classes CSS para dropdown com estado visível/oculto.

```ruby
sidebar_dropdown_classes(['/admin/professionals'], 'translate transform overflow-hidden')
# Retorna: "translate transform overflow-hidden" ou "translate transform overflow-hidden hidden"
```

### `sidebar_group_expanded?(group_paths)`
Retorna "true" ou "false" para `aria-expanded`.

```ruby
sidebar_group_expanded?(['/admin/professionals']) # "true" ou "false"
```

## 2. Uso no HTML/ERB

### Item de Menu Simples
```erb
<a href="/admin/dashboard" 
   class="<%= sidebar_menu_item_classes('/admin/dashboard', 'menu-item group') %>">
  Dashboard
</a>
```

### Grupo Colapsável
```erb
<!-- Botão do grupo -->
<a href="#" 
   role="button"
   data-action="click->sidebar#toggleGroup"
   data-sidebar-name-param="Profissionais"
   aria-expanded="<%= sidebar_group_expanded?(['/admin/professionals']) %>"
   class="<%= sidebar_group_classes(['/admin/professionals']) %>">
  Profissionais
</a>

<!-- Dropdown do grupo -->
<div class="<%= sidebar_dropdown_classes(['/admin/professionals'], 'translate transform overflow-hidden') %>">
  <ul class="menu-dropdown">
    <li>
      <a href="/admin/professionals" 
         class="<%= sidebar_menu_item_classes('/admin/professionals', 'menu-dropdown-link') %>">
        Lista de Profissionais
      </a>
    </li>
    <li>
      <a href="/admin/professionals/new" 
         class="<%= sidebar_menu_item_classes('/admin/professionals/new', 'menu-dropdown-link') %>">
        Novo Profissional
      </a>
    </li>
  </ul>
</div>
```

## 3. Configuração de Grupos

### Definição de Grupos
Cada grupo deve ter um array de paths que pertencem a ele:

```ruby
# Dashboard
['/admin/dashboard']

# Profissionais
['/admin/professionals', '/admin/professionals/new', '/admin/professionals/edit']

# Especialidades
['/admin/specialities', '/admin/specialities/new', '/admin/specialities/edit']

# Tipos de Contrato
['/admin/contract_types', '/admin/contract_types/new', '/admin/contract_types/edit']
```

### Exemplo Completo
```erb
<!-- Grupo Dashboard -->
<li data-sidebar-group="Dashboard">
  <a href="#" 
     data-action="click->sidebar#toggleGroup"
     data-sidebar-name-param="Dashboard"
     aria-expanded="<%= sidebar_group_expanded?(['/admin/dashboard']) %>"
     class="<%= sidebar_group_classes(['/admin/dashboard']) %>">
    Dashboard
  </a>
  
  <div class="<%= sidebar_dropdown_classes(['/admin/dashboard']) %>">
    <a href="/admin/dashboard" 
       class="<%= sidebar_menu_item_classes('/admin/dashboard') %>">
      Analytics
    </a>
  </div>
</li>

<!-- Grupo Profissionais -->
<li data-sidebar-group="Profissionais">
  <a href="#" 
     data-action="click->sidebar#toggleGroup"
     data-sidebar-name-param="Profissionais"
     aria-expanded="<%= sidebar_group_expanded?(['/admin/professionals']) %>"
     class="<%= sidebar_group_classes(['/admin/professionals']) %>">
    Profissionais
  </a>
  
  <div class="<%= sidebar_dropdown_classes(['/admin/professionals']) %>">
    <a href="/admin/professionals" 
       class="<%= sidebar_menu_item_classes('/admin/professionals') %>">
      Lista
    </a>
    <a href="/admin/professionals/new" 
       class="<%= sidebar_menu_item_classes('/admin/professionals/new') %>">
      Novo
    </a>
  </div>
</li>
```

## 4. Comportamento

### Estado Ativo
- **Item simples**: Classe `menu-item-active` quando na página
- **Grupo**: Classe `menu-item-active` quando qualquer item do grupo está ativo
- **Dropdown**: Visível quando grupo está ativo, oculto quando inativo

### Navegação
- Ao navegar para uma página, o grupo correspondente abre automaticamente
- O item específico fica destacado
- Estado persistido durante a sessão

### Acessibilidade
- `aria-expanded` atualizado automaticamente
- Navegação por teclado suportada
- Estados visuais claros

## 5. Vantagens

1. **Automático**: Não precisa de JavaScript para estado inicial
2. **Consistente**: Mesma lógica para todos os menus
3. **Manutenível**: Centralizado nos helpers
4. **Acessível**: ARIA attributes corretos
5. **Flexível**: Suporta grupos complexos
6. **Performance**: Lógica no servidor, sem JavaScript adicional

## 6. CSS Necessário

```css
.menu-item-active {
  background-color: #f3f4f6;
  color: #1f2937;
}

.menu-dropdown-link.menu-item-active {
  background-color: #e5e7eb;
  font-weight: 600;
}

/* Dark mode */
.dark .menu-item-active {
  background-color: #374151;
  color: #f9fafb;
}
```

Os helpers garantem que a navegação seja intuitiva e que o usuário sempre saiba onde está no sistema.
