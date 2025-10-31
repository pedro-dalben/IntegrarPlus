# Notificações para Chat e Chamados

## Notificações de Chat

### 1. Nova Mensagem no Chat
**Tipo:** `chat_message_received`
**Quando:** Quando alguém envia uma mensagem no chat de um beneficiário
**Quem recebe:**
- Todos os profissionais relacionados ao beneficiário
- Secretárias (se tiverem permissão para ver o chat)
- Não notifica o próprio autor da mensagem

**Conteúdo:**
- Título: "Nova mensagem no chat de {{beneficiary_name}}"
- Mensagem: "{{sender_name}} enviou uma mensagem: {{message_preview}}"
- Canal padrão: `in_app` (com opção de email se configurado)
- Metadata: `beneficiary_id`, `message_id`, `sender_id`

**Preferências:**
- Permitir desabilitar notificações de chat
- Opções: apenas in_app, email também, ou desabilitado

---

## Notificações de Chamados

### 1. Novo Chamado Criado
**Tipo:** `ticket_created`
**Quando:** Quando um novo chamado é criado para um beneficiário
**Quem recebe:**
- Todos os profissionais relacionados ao beneficiário
- Secretárias (se tiverem permissão)
- O profissional atribuído (se já for atribuído na criação)

**Conteúdo:**
- Título: "Novo chamado: {{ticket_title}}"
- Mensagem: "{{creator_name}} criou um chamado para {{beneficiary_name}}: {{ticket_title}}"
- Canal padrão: `in_app` e `email`
- Metadata: `ticket_id`, `beneficiary_id`, `creator_id`, `status`

---

### 2. Chamado Atribuído
**Tipo:** `ticket_assigned`
**Quando:** Quando um chamado é atribuído a um profissional
**Quem recebe:**
- O profissional que foi atribuído
- O criador do chamado (se diferente)

**Conteúdo:**
- Título: "Chamado atribuído a você"
- Mensagem: "Você foi atribuído ao chamado '{{ticket_title}}' do beneficiário {{beneficiary_name}}"
- Canal padrão: `in_app` e `email`
- Metadata: `ticket_id`, `beneficiary_id`, `assigned_professional_id`

---

### 3. Status do Chamado Alterado
**Tipo:** `ticket_status_changed`
**Quando:** Quando o status de um chamado muda (ex: open → in_progress → resolved)
**Quem recebe:**
- O criador do chamado
- O profissional atribuído (se houver)
- Profissionais relacionados (se status for resolvido/fechado)

**Conteúdo:**
- Título: "Status do chamado atualizado"
- Mensagem: "O chamado '{{ticket_title}}' foi atualizado para {{new_status}}"
- Canal padrão: `in_app`
- Metadata: `ticket_id`, `beneficiary_id`, `old_status`, `new_status`, `changed_by_id`

---

### 4. Chamado Resolvido/Fechado
**Tipo:** `ticket_resolved` / `ticket_closed`
**Quando:** Quando um chamado é marcado como resolvido ou fechado
**Quem recebe:**
- O criador do chamado
- O profissional atribuído
- Todos os profissionais relacionados (resumo)

**Conteúdo:**
- Título: "Chamado {{status_label}}"
- Mensagem: "O chamado '{{ticket_title}}' do beneficiário {{beneficiary_name}} foi {{status_label}} por {{resolved_by_name}}"
- Canal padrão: `in_app` e `email`
- Metadata: `ticket_id`, `beneficiary_id`, `resolved_by_id`, `status`

---

## Implementação Sugerida

### 1. Adicionar novos tipos ao enum de Notification
```ruby
chat_message_received: 'chat_message_received',
ticket_created: 'ticket_created',
ticket_assigned: 'ticket_assigned',
ticket_status_changed: 'ticket_status_changed',
ticket_resolved: 'ticket_resolved',
ticket_closed: 'ticket_closed'
```

### 2. Callbacks nos modelos
- `BeneficiaryChatMessage`: `after_create_commit` → notificar profissionais relacionados
- `BeneficiaryTicket`:
  - `after_create_commit` → notificar novo chamado
  - `after_update_commit` → notificar mudança de status/atribuição

### 3. Service Methods
Criar métodos no `NotificationService`:
- `send_chat_message_notification(message)`
- `send_ticket_created_notification(ticket)`
- `send_ticket_assigned_notification(ticket, assigned_to)`
- `send_ticket_status_changed_notification(ticket, old_status, changed_by)`
- `send_ticket_resolved_notification(ticket, resolved_by)`

### 4. Preferências de Notificação
Adicionar preferências no `NotificationPreference`:
- `chat_messages` (notificações de chat)
- `ticket_created` (novos chamados)
- `ticket_assigned` (quando atribuído a mim)
- `ticket_updates` (atualizações de chamados)

### 5. Considerações
- Não notificar o próprio autor da ação
- Respeitar preferências de notificação do usuário
- Permitir configuração de canais (in_app, email, sms, push)
- Agrupar notificações quando houver muitas mensagens/chamados
