# Agenda Unificada por Profissional

## Visão Geral
Sistema de agenda unificada que permite aos profissionais gerenciar eventos pessoais e institucionais em uma única interface, com controle de privacidade e visibilidade baseado no contexto de uso.

## Stack Tecnológica
- Rails 8.0.2
- PostgreSQL
- Hotwire (Turbo/Stimulus)
- Tailwind CSS
- View Components

## Arquitetura

### Modelo de Dados
- **Event**: Tabela única para todos os tipos de eventos
- **Professional**: Já existente, dono da agenda
- **User**: Já existente, criador do evento

### Tipos de Evento
- `personal`: Eventos pessoais do profissional
- `consulta`: Consultas médicas/atendimentos
- `atendimento`: Atendimentos diversos
- `reuniao`: Reuniões institucionais
- `outro`: Outros tipos de eventos

### Escopo de Visibilidade
- `private`: Só o próprio profissional vê detalhes
- `restricted`: Detalhes visíveis apenas para quem tem permissão
- `public`: Detalhes visíveis para perfis autorizados

## Tarefas de Implementação

### 1. Estrutura de Banco de Dados
- [ ] Migration para tabela `events`
- [ ] Índices para performance de consultas
- [ ] Constraints de validação

### 2. Models e Associações
- [ ] Model `Event` com enums e validações
- [ ] Associações com `Professional` e `User`
- [ ] Escopos para consultas de disponibilidade
- [ ] Métodos para controle de visibilidade

### 3. Controllers
- [ ] `EventsController` para CRUD básico
- [ ] `ProfessionalAgendasController` para consultas institucionais
- [ ] Endpoints JSON para Hotwire/Stimulus

### 4. View Components
- [ ] `CalendarComponent` para exibição do calendário
- [ ] `EventFormComponent` para criação/edição
- [ ] `EventCardComponent` para exibição de eventos
- [ ] `AvailabilityGridComponent` para consultas institucionais

### 5. Stimulus Controllers
- [ ] `CalendarController` para interações do calendário
- [ ] `EventModalController` para modal de eventos
- [ ] `AvailabilityController` para consultas de disponibilidade

### 6. Views
- [ ] Dashboard do profissional com agenda pessoal
- [ ] Tela de agendamento institucional
- [ ] Formulários de criação/edição de eventos

### 7. Serviços
- [ ] `EventAvailabilityService` para consultas de disponibilidade
- [ ] `EventConflictService` para detecção de conflitos
- [ ] `EventVisibilityService` para controle de visibilidade

### 8. Testes
- [ ] Testes de modelo para validações
- [ ] Testes de controller para endpoints
- [ ] Testes de integração para fluxos completos

## Endpoints da API

### Dashboard do Profissional
```
GET /professional/agenda
GET /professional/agenda/events.json
```

### Agendamento Institucional
```
GET /professional/:id/availability
GET /professional/:id/events.json
POST /professional/:id/events
```

## Regras de Negócio

### Privacidade
- Profissionais veem todos os seus eventos com detalhes completos
- Usuários institucionais veem apenas disponibilidade para eventos private/restricted
- Eventos public são sempre visíveis com detalhes completos

### Validações
- `end_time` deve ser maior que `start_time`
- Não pode haver sobreposição de horários para o mesmo profissional
- Campos obrigatórios: title, start_time, end_time, event_type, visibility_scope

### Conflitos
- Sistema detecta automaticamente sobreposições
- Retorna erro informativo quando há conflito
- Permite visualizar eventos conflitantes

## Evolução Futura

### Múltiplas Agendas
- Estrutura preparada para tabela `calendars` futura
- Campo `calendar_id` opcional para compatibilidade
- Migração simples sem quebra de funcionalidade

### Equipes e Recursos
- Campo `resource_type` para diferentes tipos de agenda
- Suporte a agendamentos de salas, equipamentos, etc.
- Permissões granulares por tipo de recurso

## Critérios de Aceite

### Funcionalidades Básicas
- [ ] Profissional vê agenda pessoal completa no dashboard
- [ ] Eventos pessoais e institucionais são diferenciados visualmente
- [ ] Criação/edição/exclusão de eventos funcionam corretamente

### Privacidade
- [ ] Eventos private/restricted são mascarados em consultas institucionais
- [ ] Eventos public são sempre visíveis com detalhes
- [ ] Dashboard pessoal mostra todos os eventos do próprio profissional

### Validações
- [ ] Conflitos de horário são detectados e reportados
- [ ] Validações de data/hora funcionam corretamente
- [ ] Enums de tipo e visibilidade funcionam conforme esperado

### Performance
- [ ] Consultas de disponibilidade são otimizadas
- [ ] Índices de banco suportam consultas frequentes
- [ ] Interface responsiva para diferentes dispositivos
