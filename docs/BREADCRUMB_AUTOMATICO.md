# 🍞 Sistema de Breadcrumb Automático

O sistema de breadcrumb do IntegrarPlus é **100% automático** e baseado no path da URL. Não é necessário configurar nada manualmente!

## 🎯 Como Funciona

### 1. **Detecção Automática**
O breadcrumb é gerado automaticamente baseado no path da URL atual:

```ruby
# Exemplo: /admin/professionals/123/edit
path_parts = ["admin", "professionals", "123", "edit"]
```

### 2. **Análise Inteligente**
O sistema analisa cada parte do path para determinar:
- **Recursos**: `professionals`, `specialities`, etc.
- **Ações**: `new`, `edit`, `show`
- **IDs**: Números que indicam um registro específico

### 3. **Geração Automática**
Baseado na análise, o breadcrumb é construído automaticamente:

```
/admin/professionals/123/edit
↓
Início > Profissionais > Editar Profissional
```

## 📋 Estrutura de Traduções

### Arquivo de Traduções por Recurso
Cada recurso tem seu próprio arquivo de traduções:

```yaml
# config/locales/admin/professionals.pt-BR.yml
pt-BR:
  admin:
    breadcrumb:
      professional: "Profissional"
      professionals: "Profissionais"
    pages:
      professional:
        index:
          title: "Profissionais"
          subtitle: "Gerencie os profissionais da plataforma"
        new:
          title: "Novo Profissional"
          subtitle: "Cadastre um novo profissional"
        edit:
          title: "Editar Profissional"
          subtitle: "Edite as informações do profissional"
        show:
          title: "Detalhes do Profissional"
          subtitle: "Visualize as informações do profissional"
```

### Convenções de Nomenclatura

#### Breadcrumb
- **Singular**: `professional` → "Profissional"
- **Plural**: `professionals` → "Profissionais"

#### Páginas
- **index**: Lista de registros
- **new**: Criar novo registro
- **edit**: Editar registro existente
- **show**: Visualizar registro

## 🔄 Exemplos de Breadcrumbs Gerados

### Páginas de Listagem
```
/admin/professionals
↓
Início > Profissionais

/admin/specialities
↓
Início > Especialidades
```

### Páginas de Criação
```
/admin/professionals/new
↓
Início > Profissionais > Novo Profissional

/admin/specialities/new
↓
Início > Especialidades > Nova Especialidade
```

### Páginas de Visualização
```
/admin/professionals/123
↓
Início > Profissionais > Detalhes do Profissional

/admin/specialities/456
↓
Início > Especialidades > Detalhes da Especialidade
```

### Páginas de Edição
```
/admin/professionals/123/edit
↓
Início > Profissionais > Editar Profissional

/admin/specialities/456/edit
↓
Início > Especialidades > Editar Especialidade
```

## 🚀 Como Criar um Novo Recurso

### 1. **Criar o Arquivo de Traduções**
```yaml
# config/locales/admin/examples.pt-BR.yml
pt-BR:
  admin:
    breadcrumb:
      example: "Example"
      examples: "Examples"
    pages:
      example:
        index:
          title: "Examples"
          subtitle: "Gerencie os examples disponíveis"
        new:
          title: "Novo Example"
          subtitle: "Cadastre um novo example"
        edit:
          title: "Editar Example"
          subtitle: "Edite as informações do example"
        show:
          title: "Detalhes do Example"
          subtitle: "Visualize as informações do example"
```

### 2. **Criar as Rotas**
```ruby
# config/routes.rb
namespace :admin do
  resources :examples
end
```

### 3. **Pronto!**
O breadcrumb será gerado automaticamente para:
- `/admin/examples` → "Início > Examples"
- `/admin/examples/new` → "Início > Examples > Novo Example"
- `/admin/examples/123` → "Início > Examples > Detalhes do Example"
- `/admin/examples/123/edit` → "Início > Examples > Editar Example"

## 🔧 Personalizações

### Fallbacks Automáticos
Se uma tradução não for encontrada, o sistema usa fallbacks:

```ruby
# Se não encontrar "admin.breadcrumb.example"
# Usa: "Example" (humanize do nome do recurso)

# Se não encontrar "admin.pages.example.index.title"
# Usa: "Examples" (humanize do nome do recurso)
```

### Traduções Customizadas
Você pode sobrescrever qualquer tradução:

```yaml
# config/locales/admin/custom.pt-BR.yml
pt-BR:
  admin:
    breadcrumb:
      professional: "Médico"  # Sobrescreve "Profissional"
    pages:
      professional:
        index:
          title: "Lista de Médicos"  # Sobrescreve "Profissionais"
```

## 🎨 Componente Breadcrumb

### Localização
```erb
<!-- app/views/layouts/admin.html.erb -->
<%= render Ui::BreadcrumbComponent.new(current_path: request.path) %>
```

### Funcionalidades Automáticas
- ✅ **Detecção de path**: Analisa automaticamente a URL
- ✅ **Traduções**: Busca nas traduções organizadas por recurso
- ✅ **Fallbacks**: Usa valores padrão se tradução não encontrada
- ✅ **Links ativos**: Último item é sempre texto, não link
- ✅ **Responsivo**: Design adaptável para mobile

## 📁 Organização de Arquivos

```
config/locales/admin/
├── dashboard.pt-BR.yml      # Dashboard
├── professionals.pt-BR.yml  # Profissionais
├── specialities.pt-BR.yml   # Especialidades
├── specializations.pt-BR.yml # Especializações
├── contract_types.pt-BR.yml # Tipos de Contrato
└── [novo_recurso].pt-BR.yml # Seu novo recurso
```

## 🚨 Troubleshooting

### Breadcrumb não aparece
1. **Verifique o arquivo de traduções**:
   ```yaml
   # Deve existir: config/locales/admin/[recurso].pt-BR.yml
   ```

2. **Verifique as chaves de tradução**:
   ```yaml
   admin:
     breadcrumb:
       [recurso]: "Nome do Recurso"
     pages:
       [recurso]:
         index:
           title: "Título da Lista"
   ```

3. **Verifique o path**:
   ```ruby
   # O path deve seguir o padrão: /admin/[recurso]
   ```

### Tradução não encontrada
1. **Verifique o nome do arquivo**: Deve ser `[recurso].pt-BR.yml`
2. **Verifique a estrutura**: Deve seguir o padrão exato
3. **Verifique o singular/plural**: Use o singular para `breadcrumb` e `pages`

### Breadcrumb incorreto
1. **Verifique o path da URL**: Deve seguir o padrão RESTful
2. **Verifique as rotas**: Deve estar no namespace `admin`
3. **Verifique o controller**: Deve estar em `Admin::`

## 🎯 Benefícios

### ✅ **Zero Configuração**
- Não precisa configurar breadcrumbs manualmente
- Funciona automaticamente para qualquer novo recurso

### ✅ **Manutenibilidade**
- Traduções organizadas por recurso
- Fácil de manter e atualizar

### ✅ **Consistência**
- Padrão uniforme em todas as telas
- Design consistente

### ✅ **Flexibilidade**
- Fácil de personalizar traduções
- Suporte a fallbacks automáticos

### ✅ **Escalabilidade**
- Funciona para qualquer número de recursos
- Organização clara de arquivos

## 📚 Exemplos Completos

### Recurso Simples
```yaml
# config/locales/admin/categories.pt-BR.yml
pt-BR:
  admin:
    breadcrumb:
      category: "Categoria"
      categories: "Categorias"
    pages:
      category:
        index:
          title: "Categorias"
          subtitle: "Gerencie as categorias disponíveis"
        new:
          title: "Nova Categoria"
          subtitle: "Cadastre uma nova categoria"
        edit:
          title: "Editar Categoria"
          subtitle: "Edite as informações da categoria"
        show:
          title: "Detalhes da Categoria"
          subtitle: "Visualize as informações da categoria"
```

### Recurso com Nome Composto
```yaml
# config/locales/admin/contract_types.pt-BR.yml
pt-BR:
  admin:
    breadcrumb:
      contract_type: "Tipo de Contrato"
      contract_types: "Tipos de Contrato"
    pages:
      contract_type:
        index:
          title: "Tipos de Contrato"
          subtitle: "Gerencie os tipos de contrato disponíveis"
        new:
          title: "Novo Tipo de Contrato"
          subtitle: "Cadastre um novo tipo de contrato"
        edit:
          title: "Editar Tipo de Contrato"
          subtitle: "Edite as informações do tipo de contrato"
        show:
          title: "Detalhes do Tipo de Contrato"
          subtitle: "Visualize as informações do tipo de contrato"
```

O sistema de breadcrumb automático torna a criação de novas telas admin muito mais simples e consistente! 🎉
