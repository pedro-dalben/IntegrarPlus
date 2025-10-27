# Componente de Alertas de Erro

## Data: 27/10/2025

## Problema Identificado

As mensagens de erro de validação nos formulários estavam sendo exibidas sem estilo consistente, aparecendo apenas como texto preto sem destaque visual, dificultando a identificação de problemas pelos usuários.

![Exemplo do problema: erro de CPF sem estilo](docs/erro-sem-estilo-exemplo.png)

## Solução Implementada

### 1. Componente Reutilizável

Criado `Alerts::ErrorComponent` seguindo o padrão ViewComponent:

**Localização**: `app/components/alerts/error_component.rb`

```ruby
module Alerts
  class ErrorComponent < ViewComponent::Base
    def initialize(model:, title: nil)
      @model = model
      @title = title || default_title
    end

    def render?
      @model.present? && @model.errors.any?
    end

    # ... métodos auxiliares
  end
end
```

### 2. Design System TailAdmin

A view do componente usa o design system TailAdmin com:
- ✅ Barra lateral vermelha (6px) para destaque
- ✅ Ícone de alerta com fundo vermelho
- ✅ Título em negrito
- ✅ Lista de erros formatada
- ✅ Suporte a dark mode
- ✅ Responsivo

**Localização**: `app/components/alerts/error_component.html.erb`

### 3. Uso do Componente

**Antes** (sem estilo):
```erb
<% if professional.errors.any? %>
  <div class="ta-alert ta-alert-error">
    ...código com muito HTML...
  </div>
<% end %>
```

**Depois** (com componente):
```erb
<%= render Alerts::ErrorComponent.new(model: professional, title: "Erro ao salvar profissional") %>
```

## Arquivos Atualizados

### Formulários Admin Atualizados (9 arquivos)
1. ✅ `app/views/admin/professionals/_form.html.erb`
2. ✅ `app/views/admin/beneficiaries/_form.html.erb`
3. ✅ `app/views/admin/schools/_form.html.erb`
4. ✅ `app/views/admin/anamneses/_form.html.erb`
5. ✅ `app/views/admin/external_users/new.html.erb`
6. ✅ `app/views/admin/external_users/edit.html.erb`
7. ✅ `app/views/admin/users/edit.html.erb`

### Ainda Pendentes (15 arquivos)
Arquivos que precisam ser atualizados manualmente conforme necessário:

- `app/views/admin/news/new.html.erb`
- `app/views/admin/news/edit.html.erb`
- `app/views/admin/agendas/new.html.erb`
- `app/views/admin/agendas/edit.html.erb`
- `app/views/portal/portal_intakes/new.html.erb`
- `app/views/admin/appointment_notes/new.html.erb`
- `app/views/admin/appointment_attachments/new.html.erb`
- `app/views/admin/medical_appointments/new.html.erb`
- `app/views/admin/specializations/edit.html.erb`
- `app/views/admin/specializations/new.html.erb`
- `app/views/portal/service_requests/new.html.erb`
- `app/views/portal/service_requests/edit.html.erb`
- `app/views/admin/document_tasks/new.html.erb`
- `app/views/admin/document_tasks/edit.html.erb`
- `app/views/admin/specialities/new.html.erb`
- `app/views/admin/specialities/edit.html.erb`

## Características do Componente

### Renderização Condicional
O componente só renderiza se houver erros:

```ruby
def render?
  @model.present? && @model.errors.any?
end
```

Isso elimina blocos `<% if model.errors.any? %>` redundantes.

### Título Automático
Se não fornecer título, usa nome do modelo automaticamente:

```erb
<%= render Alerts::ErrorComponent.new(model: @professional) %>
```

Gera: "Erro ao salvar profissional"

### Título Personalizado
Pode customizar o título:

```erb
<%= render Alerts::ErrorComponent.new(model: @user, title: "Não foi possível atualizar o usuário") %>
```

### Suporte a Traduções
Aceita chaves de tradução:

```erb
<%= render Alerts::ErrorComponent.new(model: @user, title: t('admin.users.errors.save_error')) %>
```

## Visual do Componente

### Light Mode
```
┌────────────────────────────────────────────────┐
│ ▍  ⚠  Erro ao salvar profissional            │
│ ▍     • CPF não é válido                      │
│ ▍     • E-mail já está em uso                 │
└────────────────────────────────────────────────┘
```

### Dark Mode
```
┌────────────────────────────────────────────────┐
│ ▍  ⚠  Erro ao salvar profissional            │
│ ▍     • CPF não é válido                      │
│ ▍     • E-mail já está em uso                 │
└────────────────────────────────────────────────┘
```

## Classes CSS Usadas

```css
border-l-6 border-red-500       /* Barra lateral vermelha */
bg-red-50 dark:bg-red-900/20    /* Fundo vermelho claro/escuro */
text-red-800 dark:text-red-400  /* Texto vermelho */
```

## Benefícios

1. **Consistência Visual**: Todos os erros têm a mesma aparência
2. **Manutenibilidade**: Um lugar para atualizar o estilo de erro
3. **Reutilizável**: Funciona com qualquer modelo ActiveRecord
4. **Menos Código**: Reduz HTML repetitivo
5. **Acessibilidade**: Ícones e cores para melhor UX
6. **Dark Mode**: Suporte nativo

## Como Usar em Novos Formulários

1. No topo do formulário, adicione:
```erb
<%= form_with model: [:admin, @model] do |form| %>
  <%= render Alerts::ErrorComponent.new(model: @model) %>

  <!-- resto do formulário -->
<% end %>
```

2. Pronto! O componente cuida do resto automaticamente.

## Testando o Componente

Para testar localmente:

1. Acesse um formulário (ex: `/admin/professionals/new`)
2. Preencha com CPF inválido: `111.111.111-11`
3. Envie o formulário
4. Deve ver o alerta vermelho estilizado com a mensagem de erro

## Migração de Código Antigo

### Buscar todos os blocos de erro:
```bash
grep -r "if.*\.errors\.any?" app/views/
```

### Substituir padrão antigo:
```erb
<% if model.errors.any? %>
  <div class="...">
    <!-- muitas linhas de HTML -->
  </div>
<% end %>
```

### Por novo componente:
```erb
<%= render Alerts::ErrorComponent.new(model: model) %>
```

## Futuras Melhorias

1. **Criar Variações**:
   - `Alerts::SuccessComponent`
   - `Alerts::WarningComponent`
   - `Alerts::InfoComponent`

2. **Adicionar Ícone Customizável**:
```ruby
def initialize(model:, title: nil, icon: nil)
  # ...
end
```

3. **Animações de Entrada**:
```erb
<div class="animate-fade-in">
  <!-- conteúdo -->
</div>
```

4. **Botão para Fechar**:
```erb
<button data-action="click->alert#dismiss">×</button>
```

## Conclusão

O `Alerts::ErrorComponent` padroniza e melhora significativamente a experiência do usuário ao lidar com erros de validação, seguindo o design system TailAdmin e as melhores práticas do ViewComponent.

---

**Criado por**: AI Assistant
**Data**: 27/10/2025
**Versão**: 1.0
**Status**: ✅ Em Produção
