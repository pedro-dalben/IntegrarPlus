# Header Component

## Descrição

Componente de header responsivo que exibe o nome do usuário no lado esquerdo e um dropdown para sair no lado direito.

## Características

- **Design minimalista**: Apenas nome do usuário e dropdown de logout
- **Responsivo**: Adapta-se a diferentes tamanhos de tela
- **Dark mode**: Suporte completo a tema escuro
- **Acessibilidade**: Inclui labels para screen readers
- **Stimulus + Alpine.js**: Combina controladores Stimulus com Alpine.js para interatividade

## Uso

```erb
<%= render Ui::HeaderComponent.new(user: current_user) %>
```

## Estrutura

### Componente Ruby (`app/components/ui/header_component.rb`)

```ruby
class Ui::HeaderComponent < ViewComponent::Base
  def initialize(user: nil)
    @user = user
  end

  private

  attr_reader :user

  def user_name
    user&.name || "Usuário Admin"
  end
end
```

### Template (`app/components/ui/header_component.html.erb`)

- **Header container**: Sticky header com z-index alto
- **Botão sidebar**: Dispara evento para toggle da sidebar
- **Nome do usuário**: Exibido no lado esquerdo
- **Dropdown de usuário**: Menu com opção de logout

### Controlador Stimulus (`app/frontend/javascript/controllers/header_component_controller.js`)

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Header component controller connected")
  }

  toggleSidebar() {
    this.dispatch("sidebar-toggle")
  }
}
```

## Funcionalidades

### Toggle da Sidebar
- O botão hamburger dispara um evento customizado `sidebar-toggle`
- A sidebar principal escuta este evento para alternar sua visibilidade

### Dropdown de Usuário
- Usa Alpine.js para gerenciar estado do dropdown
- Inclui ícone de usuário e opção de logout
- Fecha automaticamente ao clicar fora

### Logout
- Usa Turbo para fazer logout sem reload da página
- Redireciona para a página de login após logout

## Classes CSS

### Header Principal
- `sticky top-0 z-40`: Header fixo no topo
- `flex h-16`: Layout flexbox com altura fixa
- `border-b`: Borda inferior
- `bg-white dark:bg-gray-800`: Background com suporte a dark mode

### Botões
- `inline-flex items-center justify-center`: Centralização de conteúdo
- `rounded-md`: Bordas arredondadas
- `transition-colors`: Transições suaves
- `focus-visible:ring-2`: Indicador de foco

### Dropdown
- `absolute right-0 top-full`: Posicionamento absoluto
- `w-48`: Largura fixa
- `shadow-lg`: Sombra para elevação
- `:class="open ? 'block' : 'hidden'"`: Controle de visibilidade

## Integração

### Com Sidebar
O header se comunica com a sidebar através de eventos customizados:

```javascript
// No header
this.dispatch("sidebar-toggle")

// Na sidebar (exemplo)
this.element.addEventListener("sidebar-toggle", () => {
  // Toggle sidebar
})
```

### Com Devise
O logout integra-se automaticamente com Devise:

```erb
<%= link_to destroy_user_session_path, 
    method: :delete,
    data: { turbo_method: :delete } do %>
  Sair
<% end %>
```

## Customização

### Cores
Para alterar as cores, modifique as classes Tailwind no template:

```erb
<!-- Header background -->
class="bg-white dark:bg-gray-800"

<!-- Text colors -->
class="text-gray-900 dark:text-gray-100"
```

### Tamanhos
Para alterar tamanhos:

```erb
<!-- Header height -->
class="h-16" <!-- 64px -->

<!-- Button size -->
class="h-10 w-10" <!-- 40px -->
```

## Acessibilidade

- **Screen readers**: Labels descritivos para botões
- **Keyboard navigation**: Suporte completo a navegação por teclado
- **Focus indicators**: Anéis de foco visíveis
- **ARIA labels**: Atributos ARIA apropriados

## Responsividade

O header é responsivo por padrão:
- **Mobile**: Botão hamburger visível, dropdown adaptado
- **Desktop**: Layout completo com todas as funcionalidades
- **Tablet**: Adaptação automática entre mobile e desktop
