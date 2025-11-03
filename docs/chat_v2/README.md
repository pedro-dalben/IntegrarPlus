# Chat V2 - Modelo Genérico de Conversas

## Visão Geral

Este documento descreve o modelo genérico de conversas (Chat V2) implementado para substituir o modelo legado de mensagens de beneficiários. O novo modelo foi projetado para ser escalável, genérico e suportar múltiplos tipos de conversas no sistema.

## Arquitetura

### Conceitos Principais

#### Service
Módulo/serviço do sistema que gerencia o tipo de conversa. Exemplos:
- `beneficiaries` - Conversas de beneficiários
- `support` - Conversas de suporte
- `leads` - Conversas de leads

#### Context (Context Type + Context ID)
Polymorphic association que identifica o contexto específico da conversa:
- Para beneficiários: `context_type: 'Beneficiary', context_id: 42`
- Para tickets: `context_type: 'Ticket', context_id: 789`
- Para leads: `context_type: 'Lead', context_id: 123`

#### Scope
Sub-escopo dentro do contexto que diferencia tipos de conversas no mesmo contexto:
- Para beneficiários: `'general'` ou `'professionals_only'`
- Para tickets: `'main'` ou `'followup'`

#### Identifier
Identificador único e determinístico gerado a partir de:
```
"{service}:#{context_type.underscore}:#{context_id}:#{scope}"
```

Exemplos:
- `beneficiaries:beneficiary:42:general`
- `beneficiaries:beneficiary:42:professionals_only`
- `support:ticket:789:main`

### Entidades

#### Conversation
Representa uma conversa no sistema.

**Campos principais:**
- `identifier`: Identificador único e determinístico
- `service`: Módulo/serviço
- `context_type` + `context_id`: Contexto polimórfico
- `scope`: Sub-escopo
- `conversation_type`: Tipo (group, direct, channel, thread)
- `next_message_number`: Contador sequencial por conversa
- `messages_count`: Total de mensagens (cached)
- `last_message_id` + `last_message_at`: Cache da última mensagem

**Índices:**
- `identifier` (unique)
- `(service, updated_at)`
- `(context_type, context_id, status, last_message_at DESC)`

#### ChatMessage
Mensagem append-only em uma conversa.

**Campos principais:**
- `conversation_id`: ID da conversa
- `message_number`: Número sequencial por conversa (1, 2, 3...)
- `sender_type` + `sender_id`: Quem enviou (polimórfico)
- `content_type`: Tipo de conteúdo (text, image, file, system, sticker)
- `body`: Conteúdo da mensagem
- `metadata`: Campos extensíveis (JSONB)

**Índices:**
- `(conversation_id, message_number)` (unique)
- `(conversation_id, message_number DESC) WHERE deleted_at IS NULL`
- `(conversation_id, created_at DESC) WHERE deleted_at IS NULL`

#### ConversationParticipation
Relacionamento entre conversa e participante.

**Campos principais:**
- `conversation_id`: ID da conversa
- `participant_type` + `participant_id`: Participante (polimórfico)
- `role`: Papel (owner, admin, member, viewer)
- `last_read_message_number`: Última mensagem lida
- `unread_count`: Contagem de não lidas (cached)
- `notifications_enabled`: Preferências de notificação
- `left_at`: Soft leave (nullable)

**Índices:**
- `(conversation_id, participant_type, participant_id)` (unique)
- `(conversation_id, participant_id)`

## Feature Flag e Dual-Write

### Feature Flag

A migração para o modelo V2 é controlada via `AppFlags`:

```ruby
AppFlags.chat_v2_enabled?  # Centraliza verificação de flag
AppFlags.chat_v2_enabled_for?(tenant)  # Permite rollout por tenant/coorte
```

**Variáveis de ambiente:**
- `CHAT_V2_ENABLED=true`: Habilita dual-write
- `CHAT_V2_ENFORCE_LEGACY_ONLY=true`: Kill switch rápido (força pular V2 mesmo se primeira flag estiver true)

Por padrão, ambas estão desabilitadas (`false`), mantendo apenas o comportamento legado.

### Dual-Write com Idempotência

O sistema implementa dual-write com idempotência garantida:

**Wrapper:** `Chat::SendMessageDualWrite`

**Fluxo:**
1. Grava mensagem no modelo legado (`beneficiary_chat_messages`) - **fonte da verdade atual**
2. Se `AppFlags.chat_v2_enabled_for?(tenant)`:
   - Gera `dedupe_key` (SHA256 de `legacy_message_id|conversation_identifier|content|timestamp_bucket`)
   - Verifica se mensagem já existe no V2 por `dedupe_key`
   - Se não existir:
     - Cria/garante existência da conversa via `ChatV2::UpsertConversation`
     - Cria mensagem no modelo V2 via `ChatV2::SendMessage`
     - Armazena `dedupe_key` na mensagem V2
3. Retorna mensagem do modelo legado (compatibilidade)

**Tratamento de erros:**
- Se falha na escrita V2: log estruturado + enfileira `ChatV2::RetrySyncJob` com backoff exponencial
- Máximo de 5 retries por mensagem
- Métricas registradas: `dualwrite.ok`, `dualwrite.fail_v2`, `dualwrite.retry_count`

### Sequenciamento Atômico

O `message_number` é incrementado atomicamente usando `UPDATE ... RETURNING`:
- Lock exclusivo na conversa (`SELECT FOR UPDATE`)
- Incremento atômico: `UPDATE conversations SET next_message_number = next_message_number + 1 RETURNING next_message_number`
- Evita race conditions e garante sequenciamento único por conversa

### Mapeamento Legado → V2

Para beneficiários, o mapeamento é:
```ruby
service: 'beneficiaries'
context_type: 'Beneficiary'
context_id: beneficiary_id
scope: chat_group  # 'general' ou 'professionals_only'
identifier: "beneficiaries:beneficiary:#{beneficiary_id}:#{chat_group}"
```

## Leitura (Fase Atual)

**IMPORTANTE:** Nesta fase, a leitura permanece 100% no modelo legado. Nenhuma mudança foi feita em controllers/APIs de leitura.

As mensagens são lidas apenas de `beneficiary_chat_messages`, mantendo o comportamento atual.

## Serviços V2

### ChatV2::UpsertConversation
Cria ou atualiza uma conversa de forma idempotente por identifier.

**Uso:**
```ruby
conversation = ChatV2::UpsertConversation.call(
  service: 'beneficiaries',
  context_type: 'Beneficiary',
  context_id: 42,
  scope: 'general',
  conversation_type: :group
)
```

### ChatV2::SendMessage
Envia uma mensagem em uma conversa, atualizando contadores atomicamente.

**Uso:**
```ruby
message = ChatV2::SendMessage.call(
  conversation: conversation,
  sender: user,
  body: 'Hello world',
  content_type: :text
)
```

**Fluxo:**
1. Lock na conversa (`SELECT FOR UPDATE`)
2. Incrementa `next_message_number` atomicamente
3. Cria mensagem com `message_number` sequencial
4. Atualiza `messages_count`, `last_message_id`, `last_message_at`

### ChatV2::MarkRead
Marca mensagens como lidas atualizando `last_read_message_number`.

**Uso:**
```ruby
participation = ChatV2::MarkRead.call(
  conversation: conversation,
  participant: user,
  message_number: 5
)
```

**Fluxo:**
1. Encontra ou cria `ConversationParticipation`
2. Atualiza `last_read_message_number` para o máximo entre atual e novo valor
3. Recalcula `unread_count`

## Próximas Fases

### Fase 2: Backfill + Dual-Read
- Migração de dados existentes do legado para V2
- Implementação de dual-read (leitura de ambas as tabelas)
- Validação de consistência

### Fase 3: Cutover
- Migração completa para leitura do modelo V2
- Remoção do modelo legado (após período de observação)

## Índices do Legado Otimizados

Como parte da Fase 1, foram adicionados índices otimizados na tabela legado:

- `idx_bcm_beneficiary_group_created_desc`: Índice DESC parcial para queries de últimas mensagens
- `idx_bcm_sender_created_desc`: Índice para histórico do sender

## Validação Pós-Deploy

### Queries de Verificação

Execute após deploy em staging/produção:

```sql
-- Duplicidade de message_number por conversa (não deve retornar linhas)
SELECT conversation_id, message_number, COUNT(*)
FROM chat_messages
GROUP BY conversation_id, message_number
HAVING COUNT(*) > 1
LIMIT 50;

-- Participação ativa duplicada (não deve retornar linhas)
SELECT conversation_id, participant_type, participant_id, COUNT(*)
FROM conversation_participations
WHERE left_at IS NULL
GROUP BY conversation_id, participant_type, participant_id
HAVING COUNT(*) > 1
LIMIT 50;

-- Buracos na numeração (apenas diagnóstico)
WITH seq AS (
  SELECT conversation_id,
         MIN(message_number) AS min_n,
         MAX(message_number) AS max_n,
         COUNT(*) AS cnt
  FROM chat_messages
  GROUP BY conversation_id
)
SELECT s.conversation_id, s.min_n, s.max_n, s.cnt,
       (s.max_n - s.min_n + 1) - s.cnt AS holes
FROM seq s
WHERE (s.max_n - s.min_n + 1) - s.cnt > 0
ORDER BY holes DESC
LIMIT 50;
```

### Rake Tasks

```bash
# Verificar integridade de índices
rake chat_v2:verify_indexes

# Backfill de participações
rake chat_v2:backfill_participations

# Rehidratação de mensagens (por período)
rake chat_v2:rehydrate_missing_v2_messages[2024-01-01,2024-01-31]
```

## Métricas e SLOs

### Métricas Registradas

- `chat.dualwrite.ok`: Mensagens gravadas com sucesso no legado
- `chat.dualwrite.fail_v2`: Falhas ao gravar no V2
- `chat.dualwrite.retry_count`: Contagem de retries (com tag `retry:N`)
- `chat.dualwrite.retry_success`: Retries bem-sucedidos
- `chat.dualwrite.retry_fail`: Retries que falharam

### SLOs Alvo

- **Taxa de falha V2**: < 0.5%
- **Latência SendMessageDualWrite**: p95 < 200ms
- **Disponibilidade**: > 99.9%
- **Consistência**: 0 duplicatas (verificado via queries de validação)

## Rollout Sugerido

### Fase 1: Staging
1. Habilitar `CHAT_V2_ENABLED=true` em staging
2. Monitorar dashboards de erros
3. Validar queries de integridade
4. Observar por 48h úteis

### Fase 2: Coorte Pequena (Produção)
1. Habilitar `CHAT_V2_ENABLED=true` globalmente
2. Implementar `AppFlags.chat_v2_enabled_for?(tenant)` para controlar coorte
3. Iniciar com 1 tenant/grupo/clinic
4. Monitorar métricas por 48h úteis

### Fase 3: Expansão Gradual
1. Expandir coorte para 10%, 50%, 100% conforme validação
2. Se ok, remover controle por coorte
3. Manter kill switch (`CHAT_V2_ENFORCE_LEGACY_ONLY`) disponível

### Fase 4: Dual-Read (Próxima Fase)
1. Implementar leitura do V2 para novas conversas
2. Manter legado como fallback
3. Validar consistência entre modelos

## Kill Switch

Em caso de problemas críticos:

```bash
# Força pular V2 imediatamente (sem restart)
CHAT_V2_ENFORCE_LEGACY_ONLY=true
```

Isso desabilita dual-write mesmo se `CHAT_V2_ENABLED=true`, retornando 100% ao comportamento legado.

## Referências

- Migrations: `db/migrate/20251031*_create_*.rb`, `db/migrate/20251031183411_add_dedupe_key_to_chat_messages.rb`
- Models: `app/models/conversation.rb`, `app/models/chat_message.rb`, `app/models/conversation_participation.rb`, `app/models/concerns/app_flags.rb`
- Services: `app/services/chat_v2/*.rb`, `app/services/chat/send_message_dual_write.rb`
- Jobs: `app/jobs/chat_v2/*.rb`
- Rake Tasks: `lib/tasks/chat_v2.rake`
- Testes: `spec/models/conversation_spec.rb`, `spec/services/chat_v2/*_spec.rb`, `spec/factories/*.rb`
