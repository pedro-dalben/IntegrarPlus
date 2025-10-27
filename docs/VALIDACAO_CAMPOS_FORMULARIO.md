# Validação Visual de Campos de Formulário

## Data: 27/10/2025

## Visão Geral

Sistema de validação visual individual para cada campo de formulário, mostrando erros diretamente no input com:
- ✅ Borda vermelha no campo com erro
- ✅ Ícone de alerta dentro do input
- ✅ Mensagem de erro específica abaixo do campo
- ✅ Suporte a dark mode

## Helper Criado

**Localização**: `app/helpers/form_error_helper.rb`

### Métodos Disponíveis

#### 1. `field_error_class(object, field)`
Retorna classes CSS apropriadas baseado se o campo tem erro.

```erb
<%= form.text_field :cpf, class: "... #{field_error_class(professional, :cpf)}" %>
```

**Com erro**: `border-error-300 dark:border-error-700 focus:border-error-300 ...`
**Sem erro**: `border-gray-300 dark:border-gray-700 focus:border-brand-300 ...`

#### 2. `field_has_error?(object, field)`
Verifica se um campo específico tem erro.

```erb
<% if field_has_error?(professional, :cpf) %>
  <!-- mostrar ícone de erro -->
<% end %>
```

#### 3. `field_error_message(object, field)`
Retorna a primeira mensagem de erro do campo.

```erb
<%= field_error_message(professional, :cpf) %>
```

## Como Usar

### Padrão Completo (Recomendado)

```erb
<div>
  <%= form.label :cpf, "CPF *", class: "mb-1.5 block text-sm font-medium text-gray-700 dark:text-gray-400" %>
  <div class="relative">
    <%= form.text_field :cpf,
        class: "shadow-theme-xs #{field_error_class(professional, :cpf)} h-11 w-full rounded-lg border bg-transparent px-4 #{'pr-10' if field_has_error?(professional, :cpf)} py-2.5 text-sm text-gray-800 placeholder:text-gray-400 focus:ring-3 focus:outline-hidden dark:bg-gray-900 dark:text-white/90",
        placeholder: "000.000.000-00",
        required: true %>

    <% if field_has_error?(professional, :cpf) %>
      <span class="absolute top-1/2 right-3.5 -translate-y-1/2">
        <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path fill-rule="evenodd" clip-rule="evenodd" d="M2.58325 7.99967C2.58325 5.00813 5.00838 2.58301 7.99992 2.58301C10.9915 2.58301 13.4166 5.00813 13.4166 7.99967C13.4166 10.9912 10.9915 13.4163 7.99992 13.4163C5.00838 13.4163 2.58325 10.9912 2.58325 7.99967ZM7.99992 1.08301C4.17995 1.08301 1.08325 4.17971 1.08325 7.99967C1.08325 11.8196 4.17995 14.9163 7.99992 14.9163C11.8199 14.9163 14.9166 11.8196 14.9166 7.99967C14.9166 4.17971 11.8199 1.08301 7.99992 1.08301ZM7.09932 5.01639C7.09932 5.51345 7.50227 5.91639 7.99932 5.91639H7.99999C8.49705 5.91639 8.89999 5.51345 8.89999 5.01639C8.89999 4.51933 8.49705 4.11639 7.99999 4.11639H7.99932C7.50227 4.11639 7.09932 4.51933 7.09932 5.01639ZM7.99998 11.8306C7.58576 11.8306 7.24998 11.4948 7.24998 11.0806V7.29627C7.24998 6.88206 7.58576 6.54627 7.99998 6.54627C8.41419 6.54627 8.74998 6.88206 8.74998 7.29627V11.0806C8.74998 11.4948 8.41419 11.8306 7.99998 11.8306Z" fill="#F04438"/>
        </svg>
      </span>
    <% end %>
  </div>

  <% if field_has_error?(professional, :cpf) %>
    <p class="text-xs text-error-500 dark:text-error-400 mt-1.5">
      <%= field_error_message(professional, :cpf) %>
    </p>
  <% end %>
</div>
```

### Elementos Importantes

#### 1. **Container Relativo**
```erb
<div class="relative">
  <!-- input e ícone aqui -->
</div>
```
Permite posicionamento absoluto do ícone.

#### 2. **Classes Dinâmicas de Erro**
```erb
class: "... #{field_error_class(professional, :cpf)} ..."
```
Muda a borda do input quando há erro.

#### 3. **Padding Right Condicional**
```erb
#{'pr-10' if field_has_error?(professional, :cpf)}
```
Adiciona espaço para o ícone quando há erro.

#### 4. **Ícone de Erro**
```erb
<% if field_has_error?(professional, :cpf) %>
  <span class="absolute top-1/2 right-3.5 -translate-y-1/2">
    <!-- SVG do ícone -->
  </span>
<% end %>
```
Mostra ícone de alerta vermelho dentro do input.

#### 5. **Mensagem de Erro**
```erb
<% if field_has_error?(professional, :cpf) %>
  <p class="text-xs text-error-500 dark:text-error-400 mt-1.5">
    <%= field_error_message(professional, :cpf) %>
  </p>
<% end %>
```
Exibe a mensagem de erro específica abaixo do campo.

## Cores de Erro Configuradas

**Localização**: `tailwind.config.mjs`

```javascript
colors: {
  error: {
    300: '#FDA29B',  // Borda (light)
    400: '#F97066',  // Texto (dark mode)
    500: '#F04438',  // Primária / Texto (light mode)
    600: '#D92D20',  // Hover
    700: '#B42318',  // Borda (dark mode)
  }
}
```

## Exemplos de Uso

### Campo de Texto Simples

```erb
<div>
  <%= form.label :full_name, "Nome Completo *" %>
  <div class="relative">
    <%= form.text_field :full_name,
        class: "#{field_error_class(@user, :full_name)} w-full ..." %>
    <% if field_has_error?(@user, :full_name) %>
      <!-- ícone -->
    <% end %>
  </div>
  <% if field_has_error?(@user, :full_name) %>
    <p class="text-xs text-error-500 mt-1.5">
      <%= field_error_message(@user, :full_name) %>
    </p>
  <% end %>
</div>
```

### Campo com Máscara (CPF, Telefone)

```erb
<div>
  <%= form.label :cpf, "CPF *" %>
  <div class="relative" data-controller="mask" data-mask-type-value="cpf">
    <%= form.text_field :cpf,
        class: "#{field_error_class(@professional, :cpf)} ...",
        data: { mask_target: "input" } %>
    <% if field_has_error?(@professional, :cpf) %>
      <!-- ícone -->
    <% end %>
  </div>
  <% if field_has_error?(@professional, :cpf) %>
    <p class="text-xs text-error-500 mt-1.5">
      <%= field_error_message(@professional, :cpf) %>
    </p>
  <% end %>
</div>
```

### Campo de Email

```erb
<div>
  <%= form.label :email, "E-mail *" %>
  <div class="relative">
    <%= form.email_field :email,
        class: "#{field_error_class(@user, :email)} ..." %>
    <% if field_has_error?(@user, :email) %>
      <!-- ícone -->
    <% end %>
  </div>
  <% if field_has_error?(@user, :email) %>
    <p class="text-xs text-error-500 mt-1.5">
      <%= field_error_message(@user, :email) %>
    </p>
  <% end %>
</div>
```

## Visual Esperado

### Sem Erro
```
┌─────────────────────────────────────┐
│ Nome Completo *                     │
│ ┌─────────────────────────────────┐ │
│ │ João da Silva                   │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### Com Erro
```
┌─────────────────────────────────────┐
│ CPF *                               │
│ ┌─────────────────────────────────┐ │
│ │ 111.111.111-11              ⚠  │ │ (borda vermelha)
│ └─────────────────────────────────┘ │
│ CPF não é válido                    │ (texto vermelho)
└─────────────────────────────────────┘
```

## Arquivos Atualizados

1. ✅ `app/helpers/form_error_helper.rb` - Helper criado
2. ✅ `tailwind.config.mjs` - Cores de erro adicionadas
3. ✅ `app/views/admin/professionals/_form.html.erb` - Campos CPF e Email atualizados

## Campos Aplicados

### Formulário de Profissionais
- ✅ CPF (com validação de formato)
- ✅ E-mail (com validação de formato e unicidade)

### Próximos Campos Sugeridos
- [ ] Nome Completo
- [ ] Telefone
- [ ] Data de Nascimento
- [ ] Todos os demais formulários

## Benefícios

1. **Feedback Imediato**: Usuário vê exatamente qual campo tem problema
2. **Visual Profissional**: Ícone e cores seguem TailAdmin
3. **Acessibilidade**: Múltiplos indicadores (cor, ícone, texto)
4. **Consistência**: Mesmo padrão em todo o sistema
5. **Dark Mode**: Totalmente suportado

## Como Aplicar em Outros Formulários

### Passo 1: Identificar campos
Liste todos os campos do formulário que precisam validação.

### Passo 2: Envolver em container relativo
```erb
<div class="relative">
  <%= form.text_field :field_name, ... %>
  <!-- ícone aqui se tiver erro -->
</div>
```

### Passo 3: Adicionar classes de erro
```erb
class: "... #{field_error_class(object, :field_name)} ..."
```

### Passo 4: Adicionar ícone condicional
```erb
<% if field_has_error?(object, :field_name) %>
  <span class="absolute top-1/2 right-3.5 -translate-y-1/2">
    <!-- SVG -->
  </span>
<% end %>
```

### Passo 5: Adicionar mensagem
```erb
<% if field_has_error?(object, :field_name) %>
  <p class="text-xs text-error-500 mt-1.5">
    <%= field_error_message(object, :field_name) %>
  </p>
<% end %>
```

## Testando

1. Acesse `/admin/professionals/new`
2. Preencha CPF inválido: `111.111.111-11`
3. Envie o formulário
4. Observe:
   - ✅ Alerta geral no topo
   - ✅ Campo CPF com borda vermelha
   - ✅ Ícone de erro dentro do campo
   - ✅ Mensagem "CPF não é válido" abaixo do campo

## Melhores Práticas

1. **Sempre usar container relativo** para posicionamento do ícone
2. **Adicionar padding-right condicional** quando houver erro
3. **Manter SVG do ícone consistente** em todos os campos
4. **Usar cores da paleta error** configurada no Tailwind
5. **Testar em dark mode** para garantir visibilidade

## Componente vs Helper

### Quando usar Helper (atual)
- ✅ Flexibilidade total no layout
- ✅ Controle completo das classes CSS
- ✅ Fácil integração com controllers existentes (masks, tom-select, etc)

### Quando criar Componente (futuro)
- Para campos muito repetitivos
- Quando o padrão estiver 100% estabelecido
- Para reduzir ainda mais código

## Conclusão

O helper `FormErrorHelper` fornece validação visual profissional em cada campo individual, complementando o alerta geral de erros e proporcionando uma experiência de usuário superior, seguindo os padrões do TailAdmin.

---

**Criado por**: AI Assistant
**Data**: 27/10/2025
**Versão**: 1.0
**Status**: ✅ Em Produção
