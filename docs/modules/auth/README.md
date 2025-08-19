# Módulo de Autenticação

## 📋 Visão Geral

Este módulo implementa um sistema de autenticação moderno e responsivo seguindo o padrão visual do TailAdmin Pro, com layout reutilizável e uma experiência de usuário elegante.

## 🎯 Estrutura Simplificada

### Auth::LayoutComponent
Componente principal que define o layout da página de autenticação com sidebar e área de conteúdo.

```erb
<%= render ::Auth::LayoutComponent.new(
  title: "Acesse sua conta",
  subtitle: "Entre com seu email e senha para acessar!"
) do %>
  <!-- Conteúdo do formulário -->
<% end %>
```

**Parâmetros:**
- `title` (String): Título principal da página
- `subtitle` (String): Subtítulo descritivo

## 🎨 Características Visuais

### Sidebar
- Gradiente azul para roxo
- Logo e branding do IntegrarPlus
- Lista de benefícios com ícones
- Responsivo (oculto em telas pequenas)

### Formulário
- Campos com foco visual aprimorado
- Placeholders informativos
- Botões com gradiente e hover effects
- Checkbox estilizado para "Lembrar de mim"

### Logo
- Usa a imagem `ChatGPT Image 14 de ago. de 2025, 16_31_37.png`
- Altura fixa de 64px (h-16)
- Centralizada no header

## 📱 Responsividade

- **Desktop**: Layout com sidebar e formulário lado a lado
- **Tablet**: Sidebar oculta, formulário centralizado
- **Mobile**: Formulário em largura total com padding adequado

## 🔧 Integração com Devise

O módulo é totalmente compatível com o Devise e inclui:

- Campos de email e senha
- Checkbox "Lembrar de mim"
- Link "Esqueci minha senha"
- Recuperação de senha completa
- Redirecionamentos automáticos
- Mensagens de erro/sucesso

## 🚀 Como Usar

### 1. Página de Login
```erb
<%= render ::Auth::LayoutComponent.new(
  title: "Acesse sua conta",
  subtitle: "Entre com seu email e senha para acessar!"
) do %>
  <%= form_for(resource, as: resource_name, url: session_path(resource_name), html: { class: 'space-y-4' }) do |f| %>
    <div>
      <%= f.label :email, "Email", class: "block text-sm font-medium text-gray-700 mb-2" %>
      <%= f.email_field :email, autofocus: true, autocomplete: "email", 
          class: "w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors",
          placeholder: "seu@email.com" %>
    </div>

    <div>
      <div class="flex items-center justify-between mb-2">
        <%= f.label :password, "Senha", class: "block text-sm font-medium text-gray-700" %>
        <%= link_to "Esqueci minha senha", new_password_path(resource_name), 
            class: "text-sm text-blue-600 hover:text-blue-500 transition-colors" %>
      </div>
      <%= f.password_field :password, autocomplete: "current-password", 
          class: "w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors",
          placeholder: "••••••••" %>
    </div>

    <% if devise_mapping.rememberable? %>
      <div class="flex items-center">
        <%= f.check_box :remember_me, class: "h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded" %>
        <%= f.label :remember_me, "Lembrar de mim", class: "ml-2 block text-sm text-gray-700" %>
      </div>
    <% end %>

    <div>
      <%= f.submit "Entrar", 
          class: "w-full flex justify-center py-3 px-4 border border-transparent rounded-lg shadow-sm text-sm font-medium text-white bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-all duration-200" %>
    </div>
  <% end %>
<% end %>
```

### 2. Página de Recuperação de Senha
```erb
<%= render ::Auth::LayoutComponent.new(
  title: "Recuperar senha",
  subtitle: "Digite seu email para receber instruções de recuperação"
) do %>
  <%= form_for(resource, as: resource_name, url: password_path(resource_name), html: { method: :post, class: 'space-y-4' }) do |f| %>
    <div>
      <%= f.label :email, "Email", class: "block text-sm font-medium text-gray-700 mb-2" %>
      <%= f.email_field :email, autofocus: true, autocomplete: "email", 
          class: "w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors",
          placeholder: "seu@email.com" %>
    </div>

    <div>
      <%= f.submit "Enviar instruções", 
          class: "w-full flex justify-center py-3 px-4 border border-transparent rounded-lg shadow-sm text-sm font-medium text-white bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-all duration-200" %>
    </div>

    <div class="text-center mt-4">
      <%= link_to "Voltar para o login", new_session_path(resource_name), 
          class: "text-sm text-blue-600 hover:text-blue-500 transition-colors" %>
    </div>
  <% end %>
<% end %>
```

### 3. Página de Nova Senha
```erb
<%= render ::Auth::LayoutComponent.new(
  title: "Nova senha",
  subtitle: "Digite sua nova senha"
) do %>
  <%= form_for(resource, as: resource_name, url: password_path(resource_name), html: { method: :put, class: 'space-y-4' }) do |f| %>
    <%= f.hidden_field :reset_password_token %>
    
    <div>
      <%= f.label :password, "Nova senha", class: "block text-sm font-medium text-gray-700 mb-2" %>
      <%= f.password_field :password, autofocus: true, autocomplete: "new-password", 
          class: "w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors",
          placeholder: "••••••••" %>
      <% if @minimum_password_length %>
        <p class="mt-1 text-sm text-gray-500">Mínimo de <%= @minimum_password_length %> caracteres</p>
      <% end %>
    </div>

    <div>
      <%= f.label :password_confirmation, "Confirmar nova senha", class: "block text-sm font-medium text-gray-700 mb-2" %>
      <%= f.password_field :password_confirmation, autocomplete: "new-password", 
          class: "w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors",
          placeholder: "••••••••" %>
    </div>

    <div>
      <%= f.submit "Alterar senha", 
          class: "w-full flex justify-center py-3 px-4 border border-transparent rounded-lg shadow-sm text-sm font-medium text-white bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-all duration-200" %>
    </div>
  <% end %>
<% end %>
```

## 🎯 Funcionalidades Disponíveis

### ✅ Implementado
- ✅ Login com email e senha
- ✅ Checkbox "Lembrar de mim"
- ✅ Link "Esqueci minha senha"
- ✅ Recuperação de senha por email
- ✅ Página de nova senha
- ✅ Layout responsivo
- ✅ Design moderno do TailAdmin Pro
- ✅ Logo personalizada

### ❌ Não Implementado
- ❌ Login com redes sociais
- ❌ Cadastro de usuários
- ❌ Verificação de email
- ❌ Bloqueio de conta

## 🎯 Vantagens da Estrutura Simplificada

1. **Simplicidade**: Apenas um componente reutilizável
2. **Manutenibilidade**: Código mais limpo e direto
3. **Performance**: Menos overhead de componentes
4. **Flexibilidade**: Fácil customização das views
5. **Compatibilidade Devise**: Totalmente integrado com o Devise

## 📁 Estrutura de Arquivos

```
app/components/
└── auth/
    └── layout_component.rb           # Layout principal de autenticação

app/views/devise/
├── sessions/
│   └── new.html.erb                 # Página de login
└── passwords/
    ├── new.html.erb                 # Página de recuperação de senha
    └── edit.html.erb                # Página de nova senha

app/assets/images/
└── ChatGPT Image 14 de ago. de 2025, 16_31_37.png  # Logo

docs/modules/auth/
└── README.md                        # Esta documentação
```

## 🎨 Personalização

### Cores do Gradiente
Para alterar as cores do gradiente, modifique as classes no `Auth::LayoutComponent`:

```css
/* Gradiente atual */
bg-gradient-to-br from-blue-600 to-purple-600

/* Exemplos de outros gradientes */
bg-gradient-to-br from-green-600 to-blue-600
bg-gradient-to-br from-purple-600 to-pink-600
bg-gradient-to-br from-orange-600 to-red-600
```

### Logo
Para alterar o logo, modifique o `image_tag` no método `header` do `Auth::LayoutComponent`:

```erb
helpers.image_tag('sua-logo.png', class: 'h-16 w-auto', alt: 'Logo')
```

### Textos da Sidebar
Para alterar os textos da sidebar, modifique os parâmetros no método `sidebar` do `Auth::LayoutComponent`.
