# Guia de Componentes TailAdmin - IntegrarPlus

## 📋 Resumo da Importação

Este projeto utiliza o **TailAdmin v2.0.1** como template base. Todos os estilos e componentes foram adaptados para usar ViewComponent e nosso sistema de tokens CSS.

## 🎨 Classes CSS TailAdmin Disponíveis

### Botões (.ta-btn)

#### Classe Base
```css
.ta-btn
```
- Estilo base para todos os botões
- `inline-flex items-center gap-2 rounded-lg px-4 py-2.5 text-sm font-medium`
- Inclui transições e estados de foco

#### Variantes
```css
.ta-btn-primary    /* Botão principal - azul TailAdmin */
.ta-btn-secondary  /* Botão secundário - borda e fundo neutro */
```

#### Exemplos de Uso
```erb
<!-- Botão Primário -->
<button class="ta-btn ta-btn-primary">Salvar</button>

<!-- Botão Secundário -->
<button class="ta-btn ta-btn-secondary">Cancelar</button>

<!-- Botão Full Width -->
<button class="ta-btn ta-btn-primary w-full">Entrar</button>
```

### Cards (.ta-card)

#### Classe Base
```css
.ta-card
```
- Estilo: `rounded-2xl border bg-white px-4 pb-3 pt-4 dark:bg-white/[0.03] sm:px-6`
- Suporte automático para modo escuro
- Bordas sutis seguindo padrão TailAdmin

#### Exemplo de Uso
```erb
<div class="ta-card">
  <h3 class="text-lg font-semibold mb-4">Título do Card</h3>
  <p>Conteúdo do card...</p>
</div>
```

### Inputs (.ta-input)

#### Classe Base
```css
.ta-input
```
- Estilo: `h-10 rounded-lg border px-3 text-sm transition-colors`
- Estados de foco com cor brand
- Background adaptável ao tema

#### Exemplo de Uso
```erb
<input type="text" class="ta-input w-full" placeholder="Digite aqui...">
<input type="email" class="ta-input w-full" placeholder="email@exemplo.com">
```

### Badges (.ta-badge)

#### Classes Disponíveis
```css
.ta-badge              /* Base */
.ta-badge-primary      /* Azul TailAdmin */
.ta-badge-success      /* Verde */
.ta-badge-warning      /* Amarelo */
.ta-badge-error        /* Vermelho */
.ta-badge-gray         /* Cinza neutro */
```

#### Exemplos de Uso
```erb
<span class="ta-badge ta-badge-primary">Novo</span>
<span class="ta-badge ta-badge-success">Ativo</span>
<span class="ta-badge ta-badge-warning">Pendente</span>
<span class="ta-badge ta-badge-error">Erro</span>
```

## 🧩 ViewComponents Disponíveis

### 1. Ui::ButtonComponent

```ruby
# Uso Básico
render Ui::ButtonComponent.new(label: "Clique aqui")

# Com variantes
render Ui::ButtonComponent.new(label: "Primário", variant: :primary)
render Ui::ButtonComponent.new(label: "Secundário", variant: :secondary)
render Ui::ButtonComponent.new(label: "Perigo", variant: :danger)
render Ui::ButtonComponent.new(label: "Fantasma", variant: :ghost)
render Ui::ButtonComponent.new(label: "Link", variant: :link)

# Com ícones
render Ui::ButtonComponent.new(label: "Novo", icon: "bi-plus")
render Ui::ButtonComponent.new(label: "Salvar", icon: "bi-check", icon_right: true)

# Como link
render Ui::ButtonComponent.new(label: "Ver mais", href: "/detalhes")

# Tamanhos
render Ui::ButtonComponent.new(label: "Pequeno", size: :sm)
render Ui::ButtonComponent.new(label: "Médio", size: :md)  # padrão
render Ui::ButtonComponent.new(label: "Grande", size: :lg)
```

### 2. Ui::AlertComponent

```ruby
# Alertas com diferentes tipos
render Ui::AlertComponent.new(kind: :success, title: "Sucesso!") do
  "Operação realizada com sucesso."
end

render Ui::AlertComponent.new(kind: :warning, title: "Atenção") do
  "Verifique os dados antes de continuar."
end

render Ui::AlertComponent.new(kind: :danger, title: "Erro") do
  "Ocorreu um erro durante o processamento."
end

render Ui::AlertComponent.new(kind: :info, title: "Informação") do
  "Dados atualizados automaticamente."
end
```

### 3. Ui::BadgeComponent

```ruby
# Badges com diferentes tons
render Ui::BadgeComponent.new(label: "Novo", tone: :brand)
render Ui::BadgeComponent.new(label: "Ativo", tone: :success)
render Ui::BadgeComponent.new(label: "Pendente", tone: :warning)
render Ui::BadgeComponent.new(label: "Inativo", tone: :danger)
render Ui::BadgeComponent.new(label: "Padrão", tone: :gray)
```

### 4. Ui::CardComponent

```ruby
# Card básico
render Ui::CardComponent.new(title: "Meu Card") do
  "Conteúdo do card aqui..."
end

# Card com ações
render Ui::CardComponent.new(title: "Card com Ação") do |c|
  c.with_actions do
    render Ui::ButtonComponent.new(label: "Editar", variant: :secondary)
  end
  
  "Conteúdo do card..."
end
```

### 5. Ui::FormFieldComponent

```ruby
# Campo de formulário com label e hint
render Ui::FormFieldComponent.new(label: "Nome Completo", hint: "Digite seu nome completo") do
  text_field_tag :nome, nil, class: "ta-input w-full"
end

# Campo obrigatório
render Ui::FormFieldComponent.new(label: "Email", required: true) do
  email_field_tag :email, nil, class: "ta-input w-full"
end
```

### 6. Ui::ProTableComponent

```ruby
# Tabela com dados
columns = [
  { key: :id, label: "ID" },
  { key: :nome, label: "Nome" },
  { key: :email, label: "Email" },
  { key: :status, label: "Status" }
]

rows = [
  { id: 1, nome: "João", email: "joao@teste.com", status: "Ativo" },
  { id: 2, nome: "Maria", email: "maria@teste.com", status: "Inativo" }
]

actions = ->(row) do
  safe_join([
    render(Ui::ButtonComponent.new(label: "Editar", variant: :ghost, size: :sm)),
    render(Ui::ButtonComponent.new(label: "Excluir", variant: :danger, size: :sm))
  ])
end

render Ui::ProTableComponent.new(columns: columns, rows: rows, actions: actions)
```

## 🎨 Sistema de Cores TailAdmin

### Cores Brand (Azul Principal)
- `--color-brand-50` até `--color-brand-950`
- Cor principal: `--color-brand-500` (#465fff)

### Cores Semânticas
- **Success**: `--color-success-50` até `--color-success-950`
- **Warning**: `--color-warning-50` até `--color-warning-950`  
- **Error**: `--color-error-50` até `--color-error-950`

### Uso nas Classes
```css
/* Nos seus componentes customizados */
.meu-componente {
  background-color: var(--color-brand-50);
  color: var(--color-brand-600);
  border-color: var(--color-brand-200);
}
```

## 📁 Estrutura de Arquivos

```
app/
├── components/
│   ├── layouts/          # Componentes de layout
│   └── ui/               # Componentes de interface
├── frontend/
│   └── styles/
│       ├── application.css    # CSS principal
│       ├── tailadmin.css     # Classes TailAdmin
│       └── tokens.css        # Variáveis CSS
└── views/                # Views usando os componentes
```

## 🚀 Boas Práticas

### 1. Sempre use as classes ta-* quando disponível
```erb
<!-- ✅ Correto -->
<button class="ta-btn ta-btn-primary">Salvar</button>

<!-- ❌ Evitar -->
<button style="background: blue; color: white; padding: 10px;">Salvar</button>
```

### 2. Prefira ViewComponents para lógica complexa
```erb
<!-- ✅ Correto -->
<%= render Ui::ButtonComponent.new(label: "Editar", variant: :secondary, icon: "bi-pencil") %>

<!-- ❌ Evitar -->
<button class="ta-btn ta-btn-secondary">
  <i class="bi bi-pencil"></i> Editar
</button>
```

### 3. Use o sistema de tokens para cores customizadas
```css
/* ✅ Correto */
.minha-classe {
  background-color: var(--color-brand-50);
}

/* ❌ Evitar */
.minha-classe {
  background-color: #ecf3ff;
}
```

### 4. Mantenha consistência com o design TailAdmin
- Use `rounded-lg` ou `rounded-xl` para bordas
- Prefira `gap-2`, `gap-3`, `gap-4` para espaçamentos
- Use `text-sm`, `text-base`, `text-lg` para tamanhos de texto

## ✅ Status de Importação

- ✅ **Cores do TailAdmin**: Todas importadas
- ✅ **Botões**: Classes base e variantes implementadas
- ✅ **Cards**: Estilo TailAdmin aplicado
- ✅ **Inputs**: Com estados de foco melhorados
- ✅ **Badges**: Todas as variantes de cor
- ✅ **Componentes ViewComponent**: Atualizados para usar classes TailAdmin
- ✅ **Modo Escuro**: Suporte automático implementado

## 📚 Referências

- [TailAdmin Documentation](https://tailadmin.com/docs)
- [ViewComponent Guide](https://viewcomponent.org/)
- [Tailwind CSS v4](https://tailwindcss.com/docs)
