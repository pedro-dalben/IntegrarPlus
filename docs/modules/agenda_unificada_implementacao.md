# Implementação da Agenda Unificada por Profissional

## Visão Geral da Implementação

Este documento descreve a implementação completa da agenda unificada por profissional, incluindo estrutura de banco de dados, modelos, controllers, views e funcionalidades.

## Estrutura Implementada

### 1. Banco de Dados

#### Tabela `events`
- **Campos principais:**
  - `title`: Título do evento (obrigatório)
  - `description`: Descrição detalhada
  - `start_time`: Data/hora de início (obrigatório)
  - `end_time`: Data/hora de fim (obrigatório)
  - `event_type`: Tipo do evento (enum)
  - `visibility_scope`: Escopo de visibilidade (enum)
  - `source_context`: Contexto para vinculação com outros módulos
  - `professional_id`: Referência ao profissional (obrigatório)
  - `created_by_id`: Referência ao usuário criador (obrigatório)
  - `status`: Status do evento (enum)

#### Enums Implementados
- **event_type:**
  - `personal`: Eventos pessoais
  - `consulta`: Consultas médicas
  - `atendimento`: Atendimentos diversos
  - `reuniao`: Reuniões institucionais
  - `outro`: Outros tipos

- **visibility_scope:**
  - `private`: Só o próprio profissional vê detalhes
  - `restricted`: Detalhes visíveis apenas para quem tem permissão
  - `public`: Detalhes sempre visíveis

- **status:**
  - `active`: Evento ativo
  - `cancelled`: Evento cancelado
  - `completed`: Evento concluído

#### Índices e Constraints
- Índices compostos para consultas eficientes
- Constraint de validação: `end_time > start_time`
- Foreign keys para `professional` e `created_by`

### 2. Models

#### Event Model
- **Associações:**
  - `belongs_to :professional`
  - `belongs_to :created_by, class_name: 'User'`

- **Validações:**
  - Campos obrigatórios
  - Validação de conflito de horários
  - Validação de data/hora

- **Escopos:**
  - `for_professional(professional_id)`
  - `in_time_range(start_time, end_time)`
  - `visible_for_user(user, professional_id)`
  - `available_slots(professional_id, start_time, end_time)`

- **Métodos:**
  - `duration_minutes`: Calcula duração em minutos
  - `conflicts_with?(other_event)`: Verifica conflitos
  - `visible_for_user?(user)`: Controle de visibilidade
  - `masked_for_institutional_view`: Mascara eventos privados

#### Professional Model
- Adicionada associação `has_many :events`

#### User Model
- Adicionada associação `has_many :events, foreign_key: :created_by_id`

### 3. Controllers

#### EventsController
- **Actions:**
  - `index`: Lista eventos do profissional
  - `show`: Visualiza evento específico
  - `new/create`: Cria novos eventos
  - `edit/update`: Edita eventos existentes
  - `destroy`: Remove eventos
  - `calendar_data`: Retorna dados para o calendário

- **Funcionalidades:**
  - CRUD completo com Hotwire/Turbo
  - Validação de conflitos
  - Controle de permissões
  - Suporte a múltiplos formatos (HTML, JSON, Turbo Stream)

#### ProfessionalAgendasController
- **Actions:**
  - `index`: Lista profissionais disponíveis
  - `show`: Visualiza agenda de um profissional
  - `availability`: Verifica disponibilidade em horário específico
  - `events_data`: Retorna eventos para calendário institucional

- **Funcionalidades:**
  - Consulta de disponibilidade
  - Visualização mascarada de eventos privados
  - Suporte a diferentes visualizações (dia, semana, mês)

### 4. View Components

#### CalendarComponent
- **Funcionalidades:**
  - Renderização do calendário FullCalendar
  - Configuração de visualizações (semana, mês, dia)
  - Filtros por tipo de evento
  - Suporte a modo somente leitura

#### EventFormComponent
- **Funcionalidades:**
  - Formulário de criação/edição
  - Validação em tempo real
  - Seleção de tipo e visibilidade
  - Campos de data/hora com validação

#### EventsListComponent
- **Funcionalidades:**
  - Lista organizada por data
  - Badges para tipo e visibilidade
  - Ações de edição/exclusão
  - Informações detalhadas dos eventos

### 5. Stimulus Controllers

#### CalendarController
- **Funcionalidades:**
  - Inicialização do FullCalendar
  - Mudança de visualização
  - Filtros por tipo
  - Drag & drop de eventos
  - Redimensionamento de eventos

#### EventModalController
- **Funcionalidades:**
  - Abertura/fechamento de modal
  - Preenchimento automático de horários
  - Validação de formulário
  - Criação/atualização via AJAX

#### AvailabilityCheckController
- **Funcionalidades:**
  - Verificação de disponibilidade
  - Exibição de conflitos
  - Interface de consulta
  - Resultados em tempo real

### 6. Serviços

#### EventAvailabilityService
- **Funcionalidades:**
  - Verificação de disponibilidade
  - Cálculo de slots livres
  - Sugestão de horários ótimos
  - Análise de conflitos
  - Estatísticas de utilização

## Como Usar

### 1. Dashboard do Profissional

#### Acessar Agenda Pessoal
```
GET /events
```

#### Visualizar Calendário
- O calendário é renderizado automaticamente
- Visualizações: semana, mês, dia
- Cores diferenciadas por tipo de evento
- Filtros por tipo de evento

#### Criar Novo Evento
1. Clicar em "Novo Evento"
2. Preencher formulário
3. Selecionar tipo e visibilidade
4. Salvar

#### Editar Evento
1. Clicar no evento no calendário
2. Modificar dados
3. Salvar alterações

### 2. Consulta Institucional

#### Listar Profissionais
```
GET /professional_agendas
```

#### Visualizar Agenda de um Profissional
```
GET /professional_agendas/:id
```

#### Verificar Disponibilidade
1. Selecionar profissional
2. Definir horário desejado
3. Clicar em "Verificar Disponibilidade"
4. Visualizar resultado

### 3. API Endpoints

#### Eventos Pessoais
```json
GET /events/calendar_data
GET /events/:id.json
POST /events
PATCH /events/:id
DELETE /events/:id
```

#### Agenda Institucional
```json
GET /professional_agendas/:id/events_data
GET /professional_agendas/:id/availability
```

## Configuração

### 1. Dependências

#### Gemfile
```ruby
# Já incluídas no Rails 8
# - view_component
# - stimulus-rails
# - tailwindcss-rails
```

#### JavaScript
```javascript
// FullCalendar (incluído via CDN nas views)
// https://cdn.jsdelivr.net/npm/fullcalendar@6.1.10/index.global.min.js
```

### 2. Variáveis de Ambiente
Nenhuma configuração adicional necessária.

### 3. Permissões
O sistema usa as permissões existentes do modelo de usuários:
- `:manage_events`: Para gerenciar eventos de outros profissionais
- Permissões padrão para eventos próprios

## Personalização

### 1. Cores dos Eventos
Editar método `event_color` em `EventsHelper`:
```ruby
def event_color(event_type)
  case event_type
  when 'personal'
    '#3b82f6'  # Azul
  when 'consulta'
    '#10b981'  # Verde
  # ... outros tipos
  end
end
```

### 2. Horários de Trabalho
Editar em `EventAvailabilityService`:
```ruby
def find_available_slots(start_date, end_date, duration_minutes = 60)
  current_time = start_date.beginning_of_day + 8.hours  # 8h
  # ... lógica
  while current_time < end_date.end_of_day - 1.hour     # 17h
```

### 3. Tipos de Evento
Adicionar novos tipos no enum do model `Event`:
```ruby
enum event_type: {
  personal: 0,
  consulta: 1,
  atendimento: 2,
  reuniao: 3,
  outro: 4,
  novo_tipo: 5  # Adicionar aqui
}
```

## Evolução Futura

### 1. Múltiplas Agendas
Para implementar múltiplas agendas (equipes, recursos):

1. Criar migration para tabela `calendars`:
```ruby
create_table :calendars do |t|
  t.string :name
  t.string :type  # team, resource, room
  t.references :owner
  t.timestamps
end
```

2. Adicionar campo `calendar_id` na tabela `events`
3. Atualizar associações nos models
4. Modificar controllers para suportar seleção de agenda

### 2. Permissões Avançadas
Para permissões granulares:

1. Criar model `EventPermission`
2. Implementar sistema de roles por evento
3. Adicionar permissões específicas por tipo de evento

### 3. Integração com Outros Módulos
Para vincular eventos a outros sistemas:

1. Usar campo `source_context` para armazenar referências
2. Implementar callbacks para sincronização
3. Criar serviços específicos para cada integração

## Troubleshooting

### 1. Problemas Comuns

#### Calendário não carrega
- Verificar se FullCalendar está carregado
- Verificar console do navegador para erros JavaScript
- Confirmar que rotas estão funcionando

#### Eventos não aparecem
- Verificar permissões do usuário
- Confirmar que eventos estão sendo criados corretamente
- Verificar logs do Rails para erros

#### Conflitos de horário
- Verificar validações no model Event
- Confirmar que constraint de banco está funcionando
- Verificar lógica de detecção de conflitos

### 2. Logs e Debug

#### Rails Logs
```bash
tail -f log/development.log
```

#### Console do Navegador
Verificar erros JavaScript e requisições de rede.

#### Console do Rails
```bash
rails console
Event.all  # Verificar eventos
Professional.first.events  # Verificar associações
```

## Testes

### 1. Executar Testes
```bash
# Todos os testes
rspec

# Apenas eventos
rspec spec/models/event_spec.rb

# Com coverage
COVERAGE=true rspec
```

### 2. Testes Implementados
- Model Event (validações, associações, métodos)
- Factory para eventos
- Testes de conflitos de horário
- Testes de visibilidade e permissões

## Conclusão

A implementação da agenda unificada por profissional está completa e funcional, atendendo a todos os requisitos especificados:

✅ **Funcionalidades Básicas:**
- CRUD completo de eventos
- Calendário interativo
- Controle de privacidade
- Detecção de conflitos

✅ **Privacidade:**
- Eventos privados mascarados em consultas institucionais
- Controle de visibilidade por contexto
- Respeito às permissões do usuário

✅ **Validações:**
- Conflitos de horário detectados automaticamente
- Validações de data/hora funcionando
- Enums configurados corretamente

✅ **Performance:**
- Índices de banco otimizados
- Consultas eficientes
- Interface responsiva

✅ **Extensibilidade:**
- Estrutura preparada para múltiplas agendas
- Serviços modulares
- Componentes reutilizáveis

A solução está pronta para uso em produção e pode ser facilmente estendida conforme as necessidades futuras do sistema.
