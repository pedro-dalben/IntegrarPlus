# Refatoração Completa do Sistema de Agendas

## Visão Geral

Esta task visa refatorar completamente o sistema de agendas para corrigir problemas críticos na funcionalidade de "Profissionais Vinculados", melhorar o fluxo de agendamento de anamnese e criar uma arquitetura mais robusta e extensível.

## Problemas Identificados

### 1. Profissionais Vinculados
- **Problema**: A busca e seleção de profissionais não está funcionando corretamente
- **Causa**: Controller JavaScript `agendas/professionals_controller.js` incompleto
- **Impacto**: Impossibilidade de vincular profissionais às agendas

### 2. Agendamento de Anamnese
- **Problema**: Agendamentos não aparecem no dashboard
- **Causa**: Falha na criação de eventos no modelo `Event` durante o agendamento
- **Impacto**: Perda de visibilidade dos agendamentos

### 3. Configuração de Horários
- **Problema**: Não há flexibilidade para configurar horários individuais por profissional
- **Causa**: Sistema atual não suporta personalização de horários
- **Impacto**: Limitação na gestão de disponibilidades

### 4. Arquitetura Fragmentada
- **Problema**: Código duplicado e inconsistente entre diferentes partes do sistema
- **Causa**: Falta de padronização e componentes reutilizáveis
- **Impacto**: Dificuldade de manutenção e extensão

## Objetivos da Refatoração

1. **Corrigir funcionalidade de profissionais vinculados**
2. **Implementar sistema flexível de horários por profissional**
3. **Garantir que agendamentos apareçam corretamente no dashboard**
4. **Criar arquitetura padronizada e extensível**
5. **Eliminar overengineering e código duplicado**

## Estrutura da Refatoração

### Fase 1: Correção dos Profissionais Vinculados

#### 1.1 Completar Controller JavaScript
**Arquivo**: `app/javascript/controllers/agendas/professionals_controller.js`

**Problemas encontrados**:
- Método `selectAllApt` não implementado
- Método `selectProfessional` incompleto
- Falta validação de seleção

**Implementações necessárias**:
```javascript
selectAllApt() {
  // Implementar seleção de todos os profissionais aptos
}

selectProfessional(event) {
  // Completar lógica de seleção individual
}

updateSelectedList() {
  // Implementar atualização da lista de selecionados
}

validateSelection() {
  // Implementar validação antes de prosseguir
}
```

#### 1.2 Melhorar Busca de Profissionais
**Arquivo**: `app/controllers/admin/agendas_controller.rb`

**Implementações necessárias**:
- Endpoint para busca AJAX de profissionais
- Filtros por especialidade e disponibilidade
- Paginação para listas grandes

#### 1.3 Refatorar View de Profissionais
**Arquivo**: `app/views/admin/agendas/_step_professionals.html.erb`

**Melhorias necessárias**:
- Melhor UX para seleção múltipla
- Indicadores visuais de seleção
- Validação em tempo real

### Fase 2: Sistema de Horários Flexível

#### 2.1 Criar Modelo de Disponibilidade
**Novo arquivo**: `app/models/professional_availability.rb`

```ruby
class ProfessionalAvailability < ApplicationRecord
  belongs_to :professional
  belongs_to :agenda, optional: true
  
  enum day_of_week: {
    monday: 0, tuesday: 1, wednesday: 2, thursday: 3,
    friday: 4, saturday: 5, sunday: 6
  }
  
  validates :start_time, :end_time, presence: true
  validates :day_of_week, presence: true
  validate :end_time_after_start_time
  
  scope :for_day, ->(day) { where(day_of_week: day) }
  scope :active, -> { where(active: true) }
end
```

#### 2.2 Criar Modelo de Exceções
**Novo arquivo**: `app/models/availability_exception.rb`

```ruby
class AvailabilityException < ApplicationRecord
  belongs_to :professional
  belongs_to :agenda, optional: true
  
  enum exception_type: {
    unavailable: 0,
    different_hours: 1,
    break: 2
  }
  
  validates :exception_date, presence: true
  validates :start_time, :end_time, presence: true, if: :different_hours?
end
```

#### 2.3 Atualizar Modelo Agenda
**Arquivo**: `app/models/agenda.rb`

**Adicionar**:
- Associação com disponibilidades
- Métodos para aplicar padrões
- Validações de horários

#### 2.4 Criar Service de Configuração de Horários
**Novo arquivo**: `app/services/availability_configuration_service.rb`

```ruby
class AvailabilityConfigurationService
  def initialize(professional, agenda = nil)
    @professional = professional
    @agenda = agenda
  end
  
  def apply_template(template_id)
    # Aplicar template de horários padrão
  end
  
  def set_custom_schedule(schedule_data)
    # Configurar horários personalizados
  end
  
  def add_exception(exception_data)
    # Adicionar exceção de horário
  end
end
```

### Fase 3: Correção do Fluxo de Agendamento

#### 3.1 Corrigir Portal Intakes Controller
**Arquivo**: `app/controllers/admin/portal_intakes_controller.rb`

**Problemas identificados**:
- Criação de `MedicalAppointment` sem criação de `Event`
- Falta de validação de disponibilidade
- Não integra com sistema de eventos

**Correções necessárias**:
```ruby
def schedule_anamnesis
  # ... código existente ...
  
  # Criar evento no sistema unificado
  event = Event.create!(
    title: "Anamnese - #{@portal_intake.beneficiary_name}",
    description: "Anamnese para #{@portal_intake.plan_name}",
    start_time: scheduled_datetime,
    end_time: scheduled_datetime + agenda.slot_duration_minutes.minutes,
    event_type: 'anamnese',
    visibility_scope: 'restricted',
    professional: professional,
    created_by: current_user,
    status: 'active',
    source_context: {
      type: 'portal_intake',
      id: @portal_intake.id
    }
  )
  
  # ... resto do código ...
end
```

#### 3.2 Criar Service de Agendamento
**Novo arquivo**: `app/services/appointment_scheduling_service.rb`

```ruby
class AppointmentSchedulingService
  def initialize(professional, agenda)
    @professional = professional
    @agenda = agenda
  end
  
  def schedule_appointment(appointment_data)
    # Validar disponibilidade
    # Criar evento
    # Criar appointment específico
    # Enviar notificações
  end
  
  def check_availability(datetime, duration)
    # Verificar se horário está disponível
  end
end
```

### Fase 4: Padronização de Views

#### 4.1 Criar Componente de Seleção de Profissionais
**Novo arquivo**: `app/components/professional_selector_component.rb`

```ruby
class ProfessionalSelectorComponent < ViewComponent::Base
  def initialize(selected_professionals: [], multiple: true, searchable: true)
    @selected_professionals = selected_professionals
    @multiple = multiple
    @searchable = searchable
  end
  
  private
  
  attr_reader :selected_professionals, :multiple, :searchable
end
```

#### 4.2 Criar Componente de Configuração de Horários
**Novo arquivo**: `app/components/schedule_configuration_component.rb`

```ruby
class ScheduleConfigurationComponent < ViewComponent::Base
  def initialize(professional:, agenda: nil, read_only: false)
    @professional = professional
    @agenda = agenda
    @read_only = read_only
  end
  
  private
  
  attr_reader :professional, :agenda, :read_only
end
```

#### 4.3 Padronizar Views de Agendamento
**Arquivos a refatorar**:
- `app/views/admin/portal_intakes/schedule_anamnesis.html.erb`
- `app/views/admin/agendas/_step_working_hours.html.erb`
- `app/views/admin/agendas/_step_review.html.erb`

**Padrões a seguir**:
- Layout de cartão consistente
- Componentes reutilizáveis
- Validação em tempo real
- Feedback visual adequado

### Fase 5: Melhorias no Dashboard

#### 5.1 Corrigir Exibição de Eventos
**Arquivo**: `app/controllers/admin/dashboard_controller.rb`

**Problemas identificados**:
- Query não inclui eventos de anamnese
- Falta filtros por tipo de evento
- Performance pode ser melhorada

**Correções necessárias**:
```ruby
def agenda_data
  {
    # Incluir todos os tipos de eventos
    this_week_events: Event.includes(:professional, :created_by)
                           .where(start_time: Date.current.all_week)
                           .order(:start_time),
    
    # Adicionar filtros por tipo
    anamnesis_events: Event.where(event_type: 'anamnese')
                           .where(start_time: Date.current.all_week),
    
    # ... resto do código ...
  }
end
```

#### 5.2 Criar Componente de Calendário Unificado
**Novo arquivo**: `app/components/unified_calendar_component.rb`

```ruby
class UnifiedCalendarComponent < ViewComponent::Base
  def initialize(events: [], professional: nil, view_type: 'month')
    @events = events
    @professional = professional
    @view_type = view_type
  end
  
  private
  
  attr_reader :events, :professional, :view_type
end
```

### Fase 6: Testes e Validação

#### 6.1 Testes de Integração
**Novos arquivos**:
- `spec/requests/agenda_professionals_spec.rb`
- `spec/requests/appointment_scheduling_spec.rb`
- `spec/services/availability_configuration_service_spec.rb`

#### 6.2 Testes de Componentes
**Novos arquivos**:
- `spec/components/professional_selector_component_spec.rb`
- `spec/components/schedule_configuration_component_spec.rb`

#### 6.3 Testes E2E
**Arquivo**: `tests/agenda_system.spec.ts`

```typescript
test('deve permitir vincular profissionais à agenda', async ({ page }) => {
  // Teste completo do fluxo de vinculação
});

test('deve agendar anamnese e exibir no dashboard', async ({ page }) => {
  // Teste do fluxo completo de agendamento
});
```

## Cronograma de Implementação

### Semana 1: Correção dos Profissionais Vinculados
- [ ] Completar controller JavaScript
- [ ] Implementar busca AJAX
- [ ] Refatorar view de seleção
- [ ] Testes unitários

### Semana 2: Sistema de Horários Flexível
- [ ] Criar modelos de disponibilidade
- [ ] Implementar service de configuração
- [ ] Atualizar modelo Agenda
- [ ] Testes de integração

### Semana 3: Correção do Fluxo de Agendamento
- [ ] Corrigir Portal Intakes Controller
- [ ] Implementar service de agendamento
- [ ] Garantir criação de eventos
- [ ] Testes E2E

### Semana 4: Padronização e Dashboard
- [ ] Criar componentes reutilizáveis
- [ ] Padronizar views
- [ ] Corrigir exibição no dashboard
- [ ] Testes finais

## Critérios de Aceitação

### Funcionalidade de Profissionais Vinculados
- [ ] Busca de profissionais funciona corretamente
- [ ] Seleção múltipla está operacional
- [ ] Validação impede prosseguir sem seleção
- [ ] Interface responsiva e intuitiva

### Sistema de Horários
- [ ] Profissionais podem ter horários personalizados
- [ ] Aplicação de templates funciona
- [ ] Exceções podem ser configuradas
- [ ] Validação de conflitos de horário

### Agendamento de Anamnese
- [ ] Agendamentos aparecem no dashboard
- [ ] Validação de disponibilidade funciona
- [ ] Criação de eventos está correta
- [ ] Notificações são enviadas

### Padronização
- [ ] Todas as views seguem layout de cartão
- [ ] Componentes são reutilizáveis
- [ ] Código está bem documentado
- [ ] Testes cobrem funcionalidades críticas

## Arquivos a Serem Criados

### Models
- `app/models/professional_availability.rb`
- `app/models/availability_exception.rb`

### Services
- `app/services/availability_configuration_service.rb`
- `app/services/appointment_scheduling_service.rb`

### Components
- `app/components/professional_selector_component.rb`
- `app/components/schedule_configuration_component.rb`
- `app/components/unified_calendar_component.rb`

### Controllers
- `app/controllers/api/professionals_controller.rb` (para busca AJAX)

### Views
- `app/views/components/professional_selector_component.html.erb`
- `app/views/components/schedule_configuration_component.html.erb`
- `app/views/components/unified_calendar_component.html.erb`

### JavaScript
- `app/javascript/controllers/professional_selector_controller.js`
- `app/javascript/controllers/schedule_configuration_controller.js`

### Testes
- `spec/models/professional_availability_spec.rb`
- `spec/services/availability_configuration_service_spec.rb`
- `spec/components/professional_selector_component_spec.rb`
- `tests/agenda_system.spec.ts`

## Migrações Necessárias

### 1. Tabela professional_availabilities
```ruby
class CreateProfessionalAvailabilities < ActiveRecord::Migration[7.1]
  def change
    create_table :professional_availabilities do |t|
      t.references :professional, null: false, foreign_key: true
      t.references :agenda, null: true, foreign_key: true
      t.integer :day_of_week, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.boolean :active, default: true
      t.text :notes
      
      t.timestamps
    end
    
    add_index :professional_availabilities, [:professional_id, :day_of_week]
    add_index :professional_availabilities, :active
  end
end
```

### 2. Tabela availability_exceptions
```ruby
class CreateAvailabilityExceptions < ActiveRecord::Migration[7.1]
  def change
    create_table :availability_exceptions do |t|
      t.references :professional, null: false, foreign_key: true
      t.references :agenda, null: true, foreign_key: true
      t.date :exception_date, null: false
      t.integer :exception_type, null: false
      t.time :start_time
      t.time :end_time
      t.text :reason
      t.boolean :active, default: true
      
      t.timestamps
    end
    
    add_index :availability_exceptions, [:professional_id, :exception_date]
    add_index :availability_exceptions, :exception_type
  end
end
```

## Considerações de Performance

### 1. Índices de Banco de Dados
- Adicionar índices compostos para consultas frequentes
- Otimizar queries de disponibilidade
- Implementar cache para dados estáticos

### 2. Cache de Dados
- Cache de profissionais ativos
- Cache de horários de disponibilidade
- Cache de eventos do dashboard

### 3. Consultas Otimizadas
- Usar `includes` para evitar N+1 queries
- Implementar paginação adequada
- Otimizar queries de busca

## Considerações de Segurança

### 1. Autorização
- Validar permissões para cada ação
- Implementar políticas adequadas
- Verificar acesso a dados sensíveis

### 2. Validação de Dados
- Sanitizar inputs do usuário
- Validar horários e datas
- Prevenir conflitos de agendamento

### 3. Auditoria
- Log de alterações em agendas
- Rastreamento de agendamentos
- Histórico de disponibilidades

## Monitoramento e Métricas

### 1. Métricas de Performance
- Tempo de resposta das consultas
- Taxa de erro nas operações
- Uso de recursos do servidor

### 2. Métricas de Negócio
- Número de agendamentos por dia
- Taxa de ocupação das agendas
- Profissionais mais utilizados

### 3. Alertas
- Falhas na criação de eventos
- Conflitos de horário não resolvidos
- Problemas de performance

## Conclusão

Esta refatoração visa transformar o sistema de agendas em uma solução robusta, flexível e fácil de manter. Com a implementação das melhorias propostas, o sistema será capaz de:

1. Gerenciar profissionais de forma eficiente
2. Configurar horários de forma flexível
3. Agendar eventos corretamente
4. Exibir informações de forma consistente
5. Ser facilmente extensível para futuras funcionalidades

A arquitetura proposta elimina overengineering, padroniza o código e cria uma base sólida para o crescimento do sistema.
