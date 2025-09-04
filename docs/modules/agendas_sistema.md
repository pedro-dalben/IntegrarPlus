# Sistema de Agendas - Documentação

## Visão Geral

O sistema de agendas permite criar e gerenciar agendas de atendimento com configurações flexíveis de horários, profissionais vinculados e políticas de visibilidade.

## Funcionalidades Implementadas

### 1. Lista de Agendas (Admin > Agendas)

**Arquivo:** `app/views/admin/agendas/index.html.erb`

- Lista todas as agendas com filtros por tipo, status e unidade
- Busca por nome ou descrição
- Ações: visualizar, editar, arquivar/ativar, duplicar, excluir
- Colunas: Nome, Tipo, Profissionais, Slots, Status, Última Atualização

### 2. Wizard de Criação (4 Etapas)

#### Etapa 1 - Metadados
**Arquivo:** `app/views/admin/agendas/_step_metadata.html.erb`

- Nome da agenda (único por unidade/tipo)
- Tipo de serviço (anamnese, consulta, atendimento, reunião, outro)
- Visibilidade padrão (privada, restrita, pública)
- Unidade (opcional)
- Cor do marcador no calendário
- Observações

#### Etapa 2 - Profissionais
**Arquivo:** `app/views/admin/agendas/_step_professionals.html.erb`

- Multi-select de profissionais com busca
- Botão "Selecionar Todos Aptos"
- Visualização de profissionais selecionados
- Validação: pelo menos 1 profissional

#### Etapa 3 - Grade de Horários
**Arquivo:** `app/views/admin/agendas/_step_working_hours.html.erb`

- Configuração de duração do slot e buffer
- Horários por dia da semana (múltiplos períodos)
- Botão "Copiar para Todos os Dias"
- Exceções (datas fechadas ou horários especiais)
- Preview de slots

#### Etapa 4 - Revisão
**Arquivo:** `app/views/admin/agendas/_step_review.html.erb`

- Resumo completo da agenda
- Lista de profissionais vinculados
- Preview de slots disponíveis
- Botões: Salvar Rascunho ou Ativar

### 3. Visualização de Agenda

**Arquivo:** `app/views/admin/agendas/show.html.erb`

- Header com nome, tipo, status e ações
- Configurações detalhadas
- Grade de horários
- Lista de profissionais
- Preview de slots
- Eventos recentes

### 4. Edição de Agenda

**Arquivo:** `app/views/admin/agendas/edit.html.erb`

- Reutiliza as etapas do wizard
- Aviso quando agenda possui eventos
- Navegação entre etapas

## Models

### Agenda
**Arquivo:** `app/models/agenda.rb`

```ruby
# Campos principais
- name: string (único por unidade/tipo)
- service_type: enum (anamnese, consulta, atendimento, reuniao, outro)
- default_visibility: enum (private, restricted, public)
- unit_id: reference (opcional)
- color_theme: string (cor hexadecimal)
- notes: text
- working_hours: json (configuração de horários)
- slot_duration_minutes: integer
- buffer_minutes: integer
- status: enum (draft, active, archived)
- created_by/updated_by: references
- lock_version: integer (optimistic locking)
```

**Validações:**
- Nome obrigatório e único por unidade/tipo
- Pelo menos 1 profissional ativo
- Estrutura JSON válida para working_hours
- Duração e buffer válidos

**Métodos:**
- `can_be_edited?` - verifica se pode ser editada
- `can_be_deleted?` - verifica se pode ser excluída
- `duplicate!` - duplica agenda
- `working_hours_summary` - resumo dos horários
- `slot_summary` - resumo dos slots

### AgendaProfessional
**Arquivo:** `app/models/agenda_professional.rb`

```ruby
# Campos
- agenda_id: reference
- professional_id: reference (para User)
- capacity_per_slot: integer (default 1)
- active: boolean (default true)
```

## Controller

### Admin::AgendasController
**Arquivo:** `app/controllers/admin/agendas_controller.rb`

**Ações:**
- `index` - lista com filtros e busca
- `show` - detalhes da agenda
- `new` - formulário de criação
- `create` - cria nova agenda
- `edit` - formulário de edição
- `update` - atualiza agenda
- `destroy` - exclui agenda (soft-delete)
- `archive` - arquiva agenda
- `activate` - ativa agenda
- `duplicate` - duplica agenda
- `preview_slots` - gera preview de slots

## Stimulus Controllers

### agendas-wizard
**Arquivo:** `app/javascript/controllers/agendas/wizard_controller.js`

- Navegação entre etapas do wizard
- Controle de botões anterior/próximo
- Gerenciamento de estado

### agendas-metadata
**Arquivo:** `app/javascript/controllers/agendas/metadata_controller.js`

- Atualização de dicas de visibilidade
- Validação em tempo real

### agendas-professionals
**Arquivo:** `app/javascript/controllers/agendas/professionals_controller.js`

- Busca e filtro de profissionais
- Seleção múltipla com chips
- Atualização de inputs hidden

### agendas-working-hours
**Arquivo:** `app/javascript/controllers/agendas/working_hours_controller.js`

- Adição/remoção de períodos
- Cópia de horários entre dias
- Validação de sobreposição
- Geração de preview

### agendas-review
**Arquivo:** `app/javascript/controllers/agendas/review_controller.js`

- Atualização de resumo
- Geração de preview de slots
- Validação final

## Rotas

```ruby
namespace :admin do
  resources :agendas do
    member do
      patch :archive
      patch :activate
      post :duplicate
      get :preview_slots
    end
  end
end
```

## Políticas

### AgendaPolicy
**Arquivo:** `app/policies/agenda_policy.rb`

- `index?` - admin ou secretaria
- `show?` - admin ou secretaria
- `create?` - admin ou secretaria
- `update?` - admin ou secretaria
- `destroy?` - apenas admin e sem eventos
- `archive?` - admin ou secretaria
- `activate?` - admin ou secretaria
- `duplicate?` - admin ou secretaria

## Estrutura de Dados

### working_hours (JSON)
```json
{
  "slot_duration": 50,
  "buffer": 10,
  "weekdays": [
    {
      "wday": 1,
      "periods": [
        {"start": "08:00", "end": "12:00"},
        {"start": "13:00", "end": "17:00"}
      ]
    }
  ],
  "exceptions": [
    {"date": "2025-09-07", "closed": true},
    {"date": "2025-09-10", "periods": [{"start": "10:00", "end": "16:00"}]}
  ]
}
```

## Integração com Eventos

- Eventos são criados dentro de uma agenda
- Validação de conflitos por profissional
- Uso da visibilidade padrão da agenda
- Não afeta eventos existentes ao alterar grade

## Critérios de Aceite

✅ Criar Agenda em wizard: consigo salvar rascunho em cada etapa e ativar ao final
✅ Profissionais: multi-select rápido, com busca e atalho "selecionar aptos"
✅ Grade: consigo adicionar múltiplos períodos por dia, copiar para todos, remover, e o sistema valida overlaps
✅ Preview de Slots mostra corretamente, por profissional, os horários livres considerando eventos existentes + buffer
✅ Show exibe resumo fiel e permite arquivar/ativar/duplicar
✅ Lista permite filtrar por tipo e status; ações funcionam sem reload (Turbo Streams)
✅ Alterar grade não apaga eventos existentes; aviso exibido

## Próximos Passos

1. Implementar integração com sistema de eventos existente
2. Adicionar testes automatizados
3. Implementar notificações para mudanças de status
4. Adicionar relatórios de utilização das agendas
5. Implementar backup/restore de configurações
