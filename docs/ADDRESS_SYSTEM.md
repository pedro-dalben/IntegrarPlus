# Sistema de Endereços

Este documento descreve o sistema de endereços implementado no IntegrarPlus, que permite adicionar endereços a qualquer modelo de forma reutilizável e escalável.

## Visão Geral

O sistema de endereços foi projetado para ser:
- **Reutilizável**: Qualquer modelo pode ter endereços
- **Flexível**: Suporte a múltiplos tipos de endereço (residencial, comercial, cobrança, etc.)
- **Integrado**: Funciona com o serviço de CEP para preenchimento automático
- **Normalizado**: Evita duplicação de campos de endereço

## Arquitetura

### 1. Modelo Address

O modelo `Address` é polimórfico e pode ser associado a qualquer modelo:

```ruby
class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true

  validates :zip_code, presence: true, format: { with: /\A\d{5}-?\d{3}\z/ }
  validates :street, :neighborhood, :city, :state, :address_type, presence: true
  validates :state, inclusion: { in: %w[AC AL AP AM BA CE DF ES GO MA MT MS MG PA PB PR PE PI RJ RN RS RO RR SC SP SE TO] }
  validates :address_type, inclusion: { in: %w[primary secondary billing shipping residential commercial] }
end
```

**Campos disponíveis:**
- `zip_code`: CEP (formato 00000-000)
- `street`: Logradouro
- `number`: Número
- `complement`: Complemento
- `neighborhood`: Bairro
- `city`: Cidade
- `state`: Estado (UF)
- `address_type`: Tipo do endereço
- `latitude/longitude`: Coordenadas geográficas

### 2. Concern Addressable

O concern `Addressable` adiciona funcionalidades de endereço a qualquer modelo:

```ruby
module Addressable
  extend ActiveSupport::Concern

  included do
    has_many :addresses, as: :addressable, dependent: :destroy
    has_one :primary_address, -> { where(address_type: 'primary') }, as: :addressable, class_name: 'Address'
    has_one :secondary_address, -> { where(address_type: 'secondary') }, as: :addressable, class_name: 'Address'

    accepts_nested_attributes_for :addresses, allow_destroy: true
    accepts_nested_attributes_for :primary_address, allow_destroy: true
  end
end
```

## Como Usar

### 1. Adicionando Endereços a um Modelo

Para adicionar suporte a endereços em qualquer modelo:

```ruby
class Professional < ApplicationRecord
  include Addressable

  # Agora o modelo tem acesso a todos os métodos de endereço
end
```

### 2. Métodos Disponíveis

Após incluir o concern, o modelo terá acesso aos seguintes métodos:

#### Associações
```ruby
professional.addresses              # Todos os endereços
professional.primary_address        # Endereço principal
professional.secondary_address      # Endereço secundário
```

#### Métodos de Consulta
```ruby
professional.address_by_type('billing')     # Busca endereço por tipo
professional.has_address?('primary')        # Verifica se tem endereço
professional.full_address('primary')        # Endereço formatado
professional.complete_address?('primary')   # Verifica se está completo
```

#### Métodos Delegados (para endereço principal)
```ruby
professional.zip_code      # CEP do endereço principal
professional.street        # Rua do endereço principal
professional.neighborhood  # Bairro do endereço principal
professional.city          # Cidade do endereço principal
professional.state         # Estado do endereço principal
professional.coordinates   # Coordenadas do endereço principal
```

#### Integração com CEP
```ruby
# Cria/atualiza endereço a partir de dados do CEP
cep_data = CepService.search('01310-100')
professional.create_address_from_cep(cep_data, type: 'primary', number: '123')
```

### 3. Usando nos Formulários

#### Formulário Simples
```erb
<%= form_with model: @professional do |form| %>
  <!-- Outros campos do modelo -->

  <!-- Seção de Endereço -->
  <div class="address-section">
    <h3>Endereço</h3>
    <%= render AddressFormComponent.new(form: form, address_type: 'primary') %>
  </div>
<% end %>
```

#### Múltiplos Endereços
```erb
<%= form_with model: @professional do |form| %>
  <!-- Endereço Residencial -->
  <div class="residential-address">
    <h3>Endereço Residencial</h3>
    <%= render AddressFormComponent.new(form: form, address_type: 'primary') %>
  </div>

  <!-- Endereço Comercial -->
  <div class="commercial-address">
    <h3>Endereço Comercial</h3>
    <%= render AddressFormComponent.new(form: form, address_type: 'secondary') %>
  </div>
<% end %>
```

### 4. Componente AddressFormComponent

O componente `AddressFormComponent` fornece um formulário completo com:
- Busca automática por CEP
- Validação de campos
- Formatação automática
- Integração com Stimulus

#### Parâmetros do Componente
```ruby
AddressFormComponent.new(
  form: form,                    # Formulário Rails
  address_type: 'primary',       # Tipo do endereço
  nested: true,                  # Usar nested attributes (padrão: true)
  required: false,               # Campos obrigatórios (padrão: false)
  show_coordinates: false        # Mostrar campos de coordenadas (padrão: false)
)
```

### 5. Controller

Para aceitar os parâmetros de endereço no controller:

```ruby
class ProfessionalsController < ApplicationController
  private

  def professional_params
    params.require(:professional).permit(
      :full_name, :email, :cpf,
      primary_address_attributes: [
        :id, :zip_code, :street, :number, :complement,
        :neighborhood, :city, :state, :latitude, :longitude, :_destroy
      ],
      secondary_address_attributes: [
        :id, :zip_code, :street, :number, :complement,
        :neighborhood, :city, :state, :latitude, :longitude, :_destroy
      ]
    )
  end
end
```

## Tipos de Endereço

O sistema suporta os seguintes tipos de endereço:

- `primary`: Endereço principal
- `secondary`: Endereço secundário
- `billing`: Endereço de cobrança
- `shipping`: Endereço de entrega
- `residential`: Endereço residencial
- `commercial`: Endereço comercial

## Integração com CEP Service

O sistema está integrado com o `CepService` para busca automática:

```ruby
# Buscar CEP e criar endereço
cep_data = CepService.search('01310-100')
if cep_data[:error].nil?
  professional.create_address_from_cep(cep_data,
    type: 'primary',
    number: '123',
    complement: 'Apt 45'
  )
end
```

## JavaScript/Stimulus

O formulário de endereço usa o controller Stimulus `cep` que:
- Formata automaticamente o CEP
- Busca dados do endereço ao sair do campo
- Preenche automaticamente os campos
- Mostra indicadores de carregamento
- Exibe mensagens de erro

## Migração de Dados Existentes

Para modelos que já possuem campos de endereço, foi criada uma migração que:
1. Migra dados existentes para a tabela `addresses`
2. Remove campos antigos do modelo original
3. Mantém compatibilidade com código existente

## Compatibilidade com Código Legado

O sistema mantém compatibilidade com métodos antigos:

```ruby
# Métodos legados ainda funcionam
professional.endereco_completo     # => professional.full_address
professional.endereco_completo?    # => professional.complete_address?
professional.tem_coordenadas?      # => professional.has_coordinates?
```

## Exemplos Práticos

### Criando um Professional com Endereço
```ruby
professional = Professional.create!(
  full_name: 'João Silva',
  email: 'joao@example.com',
  cpf: '123.456.789-00'
)

# Buscar CEP e criar endereço
cep_data = CepService.search('01310-100')
professional.create_address_from_cep(cep_data, number: '1000')

puts professional.full_address
# => "Avenida Paulista, Bela Vista, São Paulo/SP, ZIP: 01310-100"
```

### Verificando Endereços
```ruby
professional.has_address?                    # => true
professional.complete_address?               # => true
professional.primary_address.coordinates_present?  # => true (se tiver coordenadas)
```

### Múltiplos Endereços
```ruby
# Endereço residencial
residential_data = CepService.search('22070-900')
professional.create_address_from_cep(residential_data, type: 'residential')

# Endereço comercial
commercial_data = CepService.search('01310-100')
professional.create_address_from_cep(commercial_data, type: 'commercial')

# Acessar endereços específicos
puts professional.address_by_type('residential').full_address
puts professional.address_by_type('commercial').full_address
```

## Vantagens do Sistema

1. **Reutilização**: Qualquer modelo pode ter endereços sem duplicar código
2. **Flexibilidade**: Suporte a múltiplos tipos de endereço
3. **Normalização**: Dados de endereço centralizados
4. **Integração**: Funciona perfeitamente com o CEP Service
5. **Compatibilidade**: Mantém código legado funcionando
6. **Escalabilidade**: Fácil de estender para novos tipos de endereço

## Próximos Passos

Para usar o sistema de endereços em outros modelos:

1. Inclua o concern `Addressable` no modelo
2. Use o `AddressFormComponent` nos formulários
3. Configure os parâmetros permitidos no controller
4. Aproveite todos os métodos disponíveis

O sistema está pronto para uso e pode ser facilmente estendido conforme necessário.
