# Serviço de Busca de CEP

Este documento descreve o serviço completo de busca de CEP implementado no sistema, incluindo API, componentes e exemplos de uso.

## Visão Geral

O serviço de busca de CEP permite:
- Busca automática de endereços através da API do Brasil API
- Componente reutilizável para formulários
- Preenchimento automático de campos de endereço
- Suporte a múltiplos endereços com prefixos
- Validação e formatação automática de CEP
- Coordenadas geográficas opcionais

## Componentes

### 1. CepService (Backend)

Serviço Ruby que consome a API do Brasil API para buscar informações de CEP.

**Localização:** `app/services/cep_service.rb`

**Uso:**
```ruby
# Buscar CEP
resultado = CepService.buscar('89010025')

# Resultado de sucesso
{
  cep: '89010025',
  logradouro: 'Rua Doutor Luiz de Freitas Melro',
  bairro: 'Centro',
  cidade: 'Blumenau',
  uf: 'SC',
  coordenadas: {
    latitude: '-26.9244749',
    longitude: '-49.0629788'
  }
}

# Resultado de erro
{ error: 'CEP não encontrado' }
```

### 2. CepController (API)

Controller que expõe a API REST para busca de CEP.

**Localização:** `app/controllers/cep_controller.rb`

**Endpoint:** `GET /cep/:cep`

**Exemplo:**
```bash
curl http://localhost:3000/cep/89010025
```

### 3. EnderecoFormComponent (Frontend)

Componente ViewComponent reutilizável para formulários de endereço com busca automática.

**Localização:**
- `app/components/endereco_form_component.rb`
- `app/components/endereco_form_component.html.erb`

### 4. CepController (Stimulus)

Controller JavaScript que gerencia a busca automática e preenchimento de campos.

**Localização:** `app/javascript/controllers/cep_controller.js`

## Como Usar

### Uso Básico

```erb
<%= form_with model: @objeto do |form| %>
  <%= render EnderecoFormComponent.new(form: form) %>
<% end %>
```

### Com Prefixo (Múltiplos Endereços)

```erb
<%= form_with model: @objeto do |form| %>
  <!-- Endereço residencial -->
  <%= render EnderecoFormComponent.new(form: form, prefix: 'residencial') %>

  <!-- Endereço comercial -->
  <%= render EnderecoFormComponent.new(form: form, prefix: 'comercial') %>
<% end %>
```

### Com Campos Obrigatórios

```erb
<%= render EnderecoFormComponent.new(form: form, required: true) %>
```

### Com Coordenadas

```erb
<%= render EnderecoFormComponent.new(form: form, show_coordinates: true) %>
```

### Usando o Helper

```erb
<%= endereco_form(form, required: true, show_coordinates: true) %>
```

## Parâmetros do Componente

| Parâmetro | Tipo | Padrão | Descrição |
|-----------|------|--------|-----------|
| `form` | FormBuilder | - | **Obrigatório.** Objeto do formulário Rails |
| `prefix` | String | nil | Prefixo para os nomes dos campos (ex: 'comercial_cep') |
| `required` | Boolean | false | Se os campos devem ser obrigatórios |
| `show_coordinates` | Boolean | false | Se deve incluir campos de coordenadas |

## Campos Gerados

### Sem Prefixo
- `cep`
- `logradouro`
- `bairro`
- `cidade`
- `uf`
- `latitude` (se show_coordinates: true)
- `longitude` (se show_coordinates: true)

### Com Prefixo
- `{prefix}_cep`
- `{prefix}_logradouro`
- `{prefix}_bairro`
- `{prefix}_cidade`
- `{prefix}_uf`
- `{prefix}_latitude` (se show_coordinates: true)
- `{prefix}_longitude` (se show_coordinates: true)

## Funcionalidades

### Formatação Automática
- CEP é formatado automaticamente para o padrão 00000-000
- Aceita entrada com ou sem formatação

### Busca Automática
- Busca é disparada quando o CEP tem 8 dígitos
- Preenchimento automático dos campos de endereço
- Indicador visual de carregamento

### Tratamento de Erros
- Mensagens de erro são exibidas temporariamente
- Campos são limpos em caso de CEP inválido
- Fallback gracioso em caso de erro de rede

### Eventos Personalizados
O componente dispara eventos que podem ser capturados por outros controllers:

```javascript
// Escutar evento de preenchimento
element.addEventListener('cep:preenchido', (event) => {
  const { endereco, coordenadas } = event.detail;
  console.log('Endereço preenchido:', endereco);
});
```

## Integração com Models

### Exemplo: Professional

```ruby
class Professional < ApplicationRecord
  # Validações de endereço
  validates :cep, format: { with: /\A\d{5}-?\d{3}\z/ }, allow_blank: true
  validates :uf, inclusion: { in: %w[AC AL AP AM BA CE DF ES GO MA MT MS MG PA PB PR PE PI RJ RN RS RO RR SC SP SE TO] }, allow_blank: true

  # Métodos auxiliares
  def endereco_completo
    return '' if [logradouro, bairro, cidade, uf].all?(&:blank?)

    partes = []
    partes << logradouro if logradouro.present?
    partes << bairro if bairro.present?
    partes << "#{cidade}/#{uf}" if cidade.present? && uf.present?
    partes << "CEP: #{cep}" if cep.present?

    partes.join(', ')
  end

  def tem_endereco_completo?
    [cep, logradouro, bairro, cidade, uf].all?(&:present?)
  end

  def tem_coordenadas?
    latitude.present? && longitude.present?
  end
end
```

### Migration

```ruby
class AddEnderecoToProfessionals < ActiveRecord::Migration[8.0]
  def change
    add_column :professionals, :cep, :string, limit: 9
    add_column :professionals, :logradouro, :string
    add_column :professionals, :bairro, :string
    add_column :professionals, :cidade, :string
    add_column :professionals, :uf, :string, limit: 2
    add_column :professionals, :latitude, :decimal, precision: 10, scale: 8
    add_column :professionals, :longitude, :decimal, precision: 11, scale: 8

    add_index :professionals, :cep
    add_index :professionals, :cidade
    add_index :professionals, :uf
  end
end
```

### Controller

```ruby
def professional_params
  params.require(:professional).permit(
    # outros parâmetros...
    :cep, :logradouro, :bairro, :cidade, :uf, :latitude, :longitude
  )
end
```

## Demonstração

Acesse `/cep_demo` para ver exemplos funcionais do componente.

## Testes

### Executar Testes do Serviço
```bash
rspec spec/services/cep_service_spec.rb
```

### Executar Testes do Controller
```bash
rspec spec/controllers/cep_controller_spec.rb
```

### Testar API Manualmente
```bash
# CEP válido
curl http://localhost:3000/cep/89010025

# CEP inválido
curl http://localhost:3000/cep/00000000
```

## Dependências

- **HTTParty**: Para requisições HTTP
- **Stimulus**: Para interatividade JavaScript
- **ViewComponent**: Para componentes reutilizáveis
- **Brasil API**: Fonte dos dados de CEP

## Configuração

### Rotas
```ruby
# config/routes.rb
get 'cep/:cep', to: 'cep#buscar', as: :buscar_cep
resources :cep_demo, only: [:index, :create]
```

### Assets
Certifique-se de que o controller Stimulus está sendo carregado:

```javascript
// app/javascript/controllers/application.js
import { application } from "./application"
import CepController from "./cep_controller"

application.register("cep", CepController)
```

## Personalização

### Estilos CSS
O componente usa classes Tailwind CSS. Para personalizar:

```erb
<!-- Sobrescrever classes no componente -->
<%= render EnderecoFormComponent.new(form: form) do %>
  <style>
    .cep-erro { @apply text-red-500 text-xs; }
  </style>
<% end %>
```

### Validações Customizadas
```ruby
# No model
validates :cep, presence: true, if: :endereco_obrigatorio?
validates :cidade, inclusion: { in: ['São Paulo', 'Rio de Janeiro'] }, if: :restringir_cidades?

private

def endereco_obrigatorio?
  # sua lógica aqui
end
```

## Troubleshooting

### CEP não é encontrado
- Verifique se o CEP existe na base da Brasil API
- Teste diretamente: https://brasilapi.com.br/api/cep/v2/89010025

### Campos não são preenchidos
- Verifique se o controller Stimulus está carregado
- Confirme que os data-attributes estão corretos
- Verifique o console do navegador para erros JavaScript

### Erro de CORS
- A Brasil API permite requisições de qualquer origem
- Se usar proxy, configure adequadamente

### Performance
- A API da Brasil API é gratuita mas pode ter rate limiting
- Considere implementar cache para CEPs frequentemente consultados

## Roadmap

- [ ] Cache de CEPs consultados
- [ ] Suporte offline com base local
- [ ] Integração com outras APIs de CEP
- [ ] Componente para React/Vue
- [ ] Validação de CEP em tempo real
- [ ] Sugestões de CEPs similares
