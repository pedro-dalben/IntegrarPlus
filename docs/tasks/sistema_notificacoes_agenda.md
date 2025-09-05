# Sistema de Notificações para Agenda - Implementação Futura

## Visão Geral

Este documento descreve a implementação de um sistema completo de notificações para o módulo de agendas, incluindo notificações em tempo real, lembretes automáticos, alertas de conflitos e relatórios periódicos.

## Arquitetura do Sistema

### 1. Componentes Principais

#### 1.1 NotificationService
- **Localização**: `app/services/notification_service.rb`
- **Responsabilidade**: Centralizar toda a lógica de notificações
- **Funcionalidades**:
  - Envio de notificações por email, SMS e push
  - Agendamento de notificações
  - Gerenciamento de templates
  - Controle de frequência de envio

#### 1.2 NotificationChannel
- **Localização**: `app/channels/notification_channel.rb`
- **Responsabilidade**: WebSocket para notificações em tempo real
- **Funcionalidades**:
  - Notificações push no navegador
  - Atualizações em tempo real da agenda
  - Alertas de conflitos instantâneos

#### 1.3 NotificationTemplate
- **Localização**: `app/models/notification_template.rb`
- **Responsabilidade**: Gerenciar templates de notificações
- **Funcionalidades**:
  - Templates personalizáveis
  - Suporte a múltiplos idiomas
  - Variáveis dinâmicas

### 2. Tipos de Notificações

#### 2.1 Notificações de Agenda
- **Criação de agenda**: Notificar administradores e profissionais
- **Alterações de horário**: Notificar todos os envolvidos
- **Conflitos detectados**: Alertas imediatos
- **Baixa ocupação**: Relatórios semanais
- **Manutenção necessária**: Lembretes mensais

#### 2.2 Notificações de Consultas
- **Agendamento**: Confirmação para paciente e profissional
- **Lembretes**: 48h, 24h e 2h antes
- **Cancelamento**: Notificação imediata
- **Reagendamento**: Confirmação da nova data
- **Não comparecimento**: Alerta para profissional
- **Conclusão**: Confirmação para paciente

#### 2.3 Notificações de Sistema
- **Alertas de emergência**: Consultas urgentes
- **Relatórios diários**: Resumo do dia
- **Relatórios semanais**: Métricas e tendências
- **Relatórios mensais**: Análise de performance

### 3. Implementação Técnica

#### 3.1 Estrutura de Banco de Dados

```ruby
# Migration: CreateNotifications
class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :type, null: false
      t.string :title, null: false
      t.text :message, null: false
      t.json :metadata
      t.boolean :read, default: false
      t.datetime :read_at
      t.datetime :scheduled_at
      t.string :status, default: 'pending'
      t.string :channel, default: 'email'
      t.timestamps
    end

    add_index :notifications, [:user_id, :read]
    add_index :notifications, [:type, :status]
    add_index :notifications, :scheduled_at
  end
end

# Migration: CreateNotificationTemplates
class CreateNotificationTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :notification_templates do |t|
      t.string :name, null: false
      t.string :type, null: false
      t.string :channel, null: false
      t.string :subject
      t.text :body, null: false
      t.json :variables
      t.boolean :active, default: true
      t.timestamps
    end

    add_index :notification_templates, [:type, :channel]
    add_index :notification_templates, :active
  end
end

# Migration: CreateNotificationPreferences
class CreateNotificationPreferences < ActiveRecord::Migration[8.0]
  def change
    create_table :notification_preferences do |t|
      t.references :user, null: false, foreign_key: true
      t.string :type, null: false
      t.boolean :email_enabled, default: true
      t.boolean :sms_enabled, default: false
      t.boolean :push_enabled, default: true
      t.json :settings
      t.timestamps
    end

    add_index :notification_preferences, [:user_id, :type], unique: true
  end
end
```

#### 3.2 Modelos

```ruby
# app/models/notification.rb
class Notification < ApplicationRecord
  belongs_to :user

  enum :type, {
    agenda_created: 'agenda_created',
    agenda_updated: 'agenda_updated',
    appointment_scheduled: 'appointment_scheduled',
    appointment_reminder: 'appointment_reminder',
    appointment_cancelled: 'appointment_cancelled',
    conflict_detected: 'conflict_detected',
    low_occupancy: 'low_occupancy',
    emergency_alert: 'emergency_alert'
  }

  enum :status, {
    pending: 'pending',
    sent: 'sent',
    failed: 'failed',
    cancelled: 'cancelled'
  }

  enum :channel, {
    email: 'email',
    sms: 'sms',
    push: 'push',
    in_app: 'in_app'
  }

  scope :unread, -> { where(read: false) }
  scope :scheduled, -> { where.not(scheduled_at: nil) }
  scope :by_type, ->(type) { where(type: type) }

  def mark_as_read!
    update!(read: true, read_at: Time.current)
  end

  def send_now!
    NotificationService.deliver(self)
  end
end

# app/models/notification_template.rb
class NotificationTemplate < ApplicationRecord
  enum :type, {
    agenda_created: 'agenda_created',
    agenda_updated: 'agenda_updated',
    appointment_scheduled: 'appointment_scheduled',
    appointment_reminder: 'appointment_reminder',
    appointment_cancelled: 'appointment_cancelled',
    conflict_detected: 'conflict_detected',
    low_occupancy: 'low_occupancy',
    emergency_alert: 'emergency_alert'
  }

  enum :channel, {
    email: 'email',
    sms: 'sms',
    push: 'push',
    in_app: 'in_app'
  }

  validates :name, presence: true
  validates :type, presence: true
  validates :channel, presence: true
  validates :body, presence: true

  def render(variables = {})
    rendered_body = body.dup
    variables.each do |key, value|
      rendered_body.gsub!("{{#{key}}}", value.to_s)
    end
    rendered_body
  end
end

# app/models/notification_preference.rb
class NotificationPreference < ApplicationRecord
  belongs_to :user

  enum :type, {
    agenda_created: 'agenda_created',
    agenda_updated: 'agenda_updated',
    appointment_scheduled: 'appointment_scheduled',
    appointment_reminder: 'appointment_reminder',
    appointment_cancelled: 'appointment_cancelled',
    conflict_detected: 'conflict_detected',
    low_occupancy: 'low_occupancy',
    emergency_alert: 'emergency_alert'
  }

  validates :user_id, uniqueness: { scope: :type }

  def enabled_channels
    channels = []
    channels << 'email' if email_enabled
    channels << 'sms' if sms_enabled
    channels << 'push' if push_enabled
    channels
  end
end
```

#### 3.3 Services

```ruby
# app/services/notification_service.rb
class NotificationService
  def self.create_notification(user, type, title, message, options = {})
    notification = Notification.create!(
      user: user,
      type: type,
      title: title,
      message: message,
      metadata: options[:metadata],
      scheduled_at: options[:scheduled_at],
      channel: options[:channel] || 'email'
    )

    if options[:send_immediately]
      deliver(notification)
    end

    notification
  end

  def self.deliver(notification)
    return unless notification.pending?

    case notification.channel
    when 'email'
      deliver_email(notification)
    when 'sms'
      deliver_sms(notification)
    when 'push'
      deliver_push(notification)
    when 'in_app'
      deliver_in_app(notification)
    end

    notification.update!(status: 'sent', sent_at: Time.current)
  rescue => e
    notification.update!(status: 'failed', error_message: e.message)
    Rails.logger.error "Failed to deliver notification #{notification.id}: #{e.message}"
  end

  def self.schedule_reminder(appointment, reminder_type)
    case reminder_type
    when '48h'
      scheduled_at = appointment.scheduled_at - 48.hours
    when '24h'
      scheduled_at = appointment.scheduled_at - 24.hours
    when '2h'
      scheduled_at = appointment.scheduled_at - 2.hours
    end

    return if scheduled_at < Time.current

    create_notification(
      appointment.patient,
      'appointment_reminder',
      "Lembrete de consulta - #{appointment.agenda.name}",
      "Você tem uma consulta agendada para #{appointment.scheduled_at.strftime('%d/%m/%Y às %H:%M')}",
      scheduled_at: scheduled_at,
      metadata: { appointment_id: appointment.id, reminder_type: reminder_type }
    )
  end

  def self.send_agenda_conflict_alert(agenda, conflicts)
    agenda.professionals.each do |professional|
      create_notification(
        professional.user,
        'conflict_detected',
        "Conflitos detectados na agenda '#{agenda.name}'",
        "Foram detectados #{conflicts.count} conflitos de horário na sua agenda.",
        metadata: { agenda_id: agenda.id, conflicts: conflicts },
        send_immediately: true
      )
    end
  end

  private

  def self.deliver_email(notification)
    template = NotificationTemplate.find_by(
      type: notification.type,
      channel: 'email'
    )

    if template
      NotificationMailer.send_notification(notification, template).deliver_now
    else
      NotificationMailer.generic_notification(notification).deliver_now
    end
  end

  def self.deliver_sms(notification)
    # Implementar integração com provedor de SMS
    # Exemplo: Twilio, AWS SNS, etc.
  end

  def self.deliver_push(notification)
    # Implementar notificações push
    # Exemplo: Firebase, OneSignal, etc.
  end

  def self.deliver_in_app(notification)
    # Notificação já está no banco de dados
    # Será exibida via WebSocket
  end
end
```

#### 3.4 Jobs

```ruby
# app/jobs/notification_delivery_job.rb
class NotificationDeliveryJob < ApplicationJob
  queue_as :notifications

  def perform(notification_id)
    notification = Notification.find(notification_id)
    NotificationService.deliver(notification)
  end
end

# app/jobs/scheduled_notification_job.rb
class ScheduledNotificationJob < ApplicationJob
  queue_as :notifications

  def perform
    Notification.where(
      status: 'pending',
      scheduled_at: ..Time.current
    ).find_each do |notification|
      NotificationDeliveryJob.perform_later(notification.id)
    end
  end
end

# app/jobs/appointment_reminder_job.rb
class AppointmentReminderJob < ApplicationJob
  queue_as :notifications

  def perform(appointment_id, reminder_type)
    appointment = MedicalAppointment.find(appointment_id)

    return if appointment.cancelled? || appointment.completed?

    NotificationService.schedule_reminder(appointment, reminder_type)
  end
end
```

#### 3.5 Mailers

```ruby
# app/mailers/notification_mailer.rb
class NotificationMailer < ApplicationMailer
  def send_notification(notification, template)
    @notification = notification
    @user = notification.user
    @rendered_body = template.render(notification.metadata || {})

    mail(
      to: @user.email,
      subject: template.subject || @notification.title
    )
  end

  def generic_notification(notification)
    @notification = notification
    @user = notification.user

    mail(
      to: @user.email,
      subject: @notification.title
    )
  end
end
```

#### 3.6 Channels (WebSocket)

```ruby
# app/channels/notification_channel.rb
class NotificationChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end

  def unsubscribed
    # Cleanup
  end

  def self.broadcast_notification(notification)
    broadcast_to(
      notification.user,
      {
        type: 'notification',
        id: notification.id,
        title: notification.title,
        message: notification.message,
        created_at: notification.created_at
      }
    )
  end
end
```

### 4. Configuração e Agendamento

#### 4.1 Cron Jobs (whenever)

```ruby
# config/schedule.rb
# Verificar notificações agendadas a cada 5 minutos
every 5.minutes do
  runner "ScheduledNotificationJob.perform_later"
end

# Enviar lembretes de consulta
every 1.hour do
  runner "AppointmentReminderJob.perform_later"
end

# Relatório diário às 8h
every 1.day, at: '8:00 am' do
  runner "DailyReportJob.perform_later"
end

# Relatório semanal às segundas 9h
every 1.week, at: '9:00 am' do
  runner "WeeklyReportJob.perform_later"
end
```

#### 4.2 Configurações

```ruby
# config/initializers/notifications.rb
Rails.application.configure do
  config.notifications = {
    email_enabled: true,
    sms_enabled: false,
    push_enabled: true,
    default_reminder_times: ['48h', '24h', '2h'],
    max_retries: 3,
    retry_delay: 5.minutes
  }
end
```

### 5. Interface do Usuário

#### 5.1 Componentes React/Stimulus

```javascript
// app/javascript/controllers/notification_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["bell", "count", "list"]

  connect() {
    this.setupWebSocket()
    this.loadNotifications()
  }

  setupWebSocket() {
    this.cable = createConsumer()
    this.subscription = this.cable.subscriptions.create(
      { channel: "NotificationChannel" },
      {
        received: (data) => {
          this.handleNotification(data)
        }
      }
    )
  }

  handleNotification(data) {
    this.updateNotificationCount()
    this.showNotificationToast(data)
  }

  updateNotificationCount() {
    fetch('/notifications/unread_count')
      .then(response => response.json())
      .then(data => {
        this.countTarget.textContent = data.count
        this.countTarget.classList.toggle('hidden', data.count === 0)
      })
  }

  showNotificationToast(notification) {
    // Implementar toast notification
  }
}
```

#### 5.2 Views

```erb
<!-- app/views/shared/_notification_bell.html.erb -->
<div data-controller="notification" class="relative">
  <button data-notification-target="bell" class="relative p-2 text-gray-600 hover:text-gray-900">
    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-5 5v-5zM4 19h6v-6H4v6z"/>
    </svg>
    <span data-notification-target="count" class="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full h-5 w-5 flex items-center justify-center hidden">
      0
    </span>
  </button>

  <div data-notification-target="list" class="hidden absolute right-0 mt-2 w-80 bg-white rounded-md shadow-lg z-50">
    <!-- Lista de notificações -->
  </div>
</div>
```

### 6. Testes

#### 6.1 Testes de Modelo

```ruby
# spec/models/notification_spec.rb
RSpec.describe Notification, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:type) }
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:message) }
  end

  describe 'enums' do
    it { should define_enum_for(:type) }
    it { should define_enum_for(:status) }
    it { should define_enum_for(:channel) }
  end

  describe '#mark_as_read!' do
    it 'marks notification as read' do
      notification = create(:notification, read: false)

      notification.mark_as_read!

      expect(notification.read).to be true
      expect(notification.read_at).to be_present
    end
  end
end
```

#### 6.2 Testes de Service

```ruby
# spec/services/notification_service_spec.rb
RSpec.describe NotificationService do
  describe '.create_notification' do
    it 'creates a notification' do
      user = create(:user)

      notification = NotificationService.create_notification(
        user,
        'appointment_scheduled',
        'Consulta agendada',
        'Sua consulta foi agendada com sucesso'
      )

      expect(notification).to be_persisted
      expect(notification.user).to eq(user)
      expect(notification.type).to eq('appointment_scheduled')
    end
  end

  describe '.schedule_reminder' do
    it 'schedules a reminder notification' do
      appointment = create(:medical_appointment, scheduled_at: 3.days.from_now)

      NotificationService.schedule_reminder(appointment, '48h')

      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.scheduled_at).to be_within(1.minute).of(appointment.scheduled_at - 48.hours)
    end
  end
end
```

### 7. Monitoramento e Logs

#### 7.1 Métricas

```ruby
# app/services/notification_metrics_service.rb
class NotificationMetricsService
  def self.delivery_rate
    total = Notification.count
    sent = Notification.sent.count
    return 0 if total.zero?

    (sent.to_f / total * 100).round(2)
  end

  def self.failure_rate
    total = Notification.count
    failed = Notification.failed.count
    return 0 if total.zero?

    (failed.to_f / total * 100).round(2)
  end

  def self.avg_delivery_time
    sent_notifications = Notification.sent.where.not(sent_at: nil)
    return 0 if sent_notifications.empty?

    total_time = sent_notifications.sum do |n|
      (n.sent_at - n.created_at).to_f
    end

    (total_time / sent_notifications.count / 60).round(2) # em minutos
  end
end
```

#### 7.2 Logs

```ruby
# config/initializers/notification_logger.rb
Rails.application.configure do
  config.notification_logger = Logger.new(Rails.root.join('log', 'notifications.log'))
end
```

### 8. Implementação por Fases

#### Fase 1: Notificações Básicas (2 semanas)
- [ ] Criar modelos e migrações
- [ ] Implementar NotificationService básico
- [ ] Configurar email notifications
- [ ] Criar templates básicos
- [ ] Implementar lembretes de consulta

#### Fase 2: Notificações Avançadas (2 semanas)
- [ ] Implementar WebSocket para notificações em tempo real
- [ ] Adicionar preferências de usuário
- [ ] Implementar notificações push
- [ ] Criar interface de notificações
- [ ] Adicionar relatórios básicos

#### Fase 3: Otimizações e Monitoramento (1 semana)
- [ ] Implementar sistema de retry
- [ ] Adicionar métricas e monitoramento
- [ ] Otimizar performance
- [ ] Implementar testes completos
- [ ] Documentação final

### 9. Considerações de Performance

- **Indexação**: Criar índices apropriados para consultas frequentes
- **Queue**: Usar background jobs para envio de notificações
- **Cache**: Cachear templates e preferências de usuário
- **Batch**: Processar notificações em lotes quando possível
- **Rate Limiting**: Implementar limitação de taxa para evitar spam

### 10. Segurança

- **Validação**: Validar todos os inputs de notificação
- **Autorização**: Verificar permissões antes de enviar notificações
- **Sanitização**: Sanitizar conteúdo HTML em notificações
- **Rate Limiting**: Limitar número de notificações por usuário
- **Auditoria**: Log de todas as notificações enviadas

### 11. Manutenção

- **Limpeza**: Job para limpar notificações antigas
- **Backup**: Backup regular dos templates e configurações
- **Monitoramento**: Alertas para falhas de entrega
- **Atualizações**: Processo para atualizar templates
- **Documentação**: Manter documentação atualizada

## Conclusão

Este sistema de notificações proporcionará uma experiência completa e profissional para os usuários do módulo de agendas, com notificações em tempo real, lembretes automáticos e relatórios detalhados. A implementação modular permite evolução gradual e manutenção facilitada.
