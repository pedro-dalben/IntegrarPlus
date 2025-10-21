# frozen_string_literal: true

class NotificationTemplate < ApplicationRecord
  self.inheritance_column = nil

  enum :type, {
    agenda_created: 'agenda_created',
    agenda_updated: 'agenda_updated',
    appointment_scheduled: 'appointment_scheduled',
    appointment_reminder: 'appointment_reminder',
    appointment_cancelled: 'appointment_cancelled',
    appointment_rescheduled: 'appointment_rescheduled',
    appointment_completed: 'appointment_completed',
    appointment_no_show: 'appointment_no_show',
    conflict_detected: 'conflict_detected',
    low_occupancy: 'low_occupancy',
    emergency_alert: 'emergency_alert',
    daily_report: 'daily_report',
    weekly_report: 'weekly_report',
    monthly_report: 'monthly_report'
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

  scope :active, -> { where(active: true) }
  scope :by_type, ->(type) { where(type: type) }
  scope :by_channel, ->(channel) { where(channel: channel) }

  def render(variables = {})
    rendered_body = body.dup
    rendered_subject = subject&.dup || ''

    variables.each do |key, value|
      placeholder = "{{#{key}}}"
      rendered_body.gsub!(placeholder, value.to_s)
      rendered_subject.gsub!(placeholder, value.to_s)
    end

    {
      subject: rendered_subject,
      body: rendered_body
    }
  end

  def self.find_for_type_and_channel(type, channel)
    find_by(type: type, channel: channel, active: true)
  end

  def self.create_default_templates
    default_templates = [
      {
        name: 'Agenda Criada - Email',
        type: 'agenda_created',
        channel: 'email',
        subject: 'Nova agenda criada: {{agenda_name}}',
        body: 'Uma nova agenda foi criada: {{agenda_name}}<br><br>Profissional: {{professional_name}}<br>Unidade: {{unit_name}}<br><br>Acesse o sistema para mais detalhes.'
      },
      {
        name: 'Consulta Agendada - Email',
        type: 'appointment_scheduled',
        channel: 'email',
        subject: 'Consulta agendada - {{agenda_name}}',
        body: 'Sua consulta foi agendada com sucesso!<br><br>Data: {{appointment_date}}<br>Horário: {{appointment_time}}<br>Profissional: {{professional_name}}<br>Agenda: {{agenda_name}}<br><br>Lembre-se de chegar com 15 minutos de antecedência.'
      },
      {
        name: 'Lembrete de Consulta - Email',
        type: 'appointment_reminder',
        channel: 'email',
        subject: 'Lembrete: Consulta {{reminder_type}} - {{agenda_name}}',
        body: 'Lembrete: Você tem uma consulta agendada!<br><br>Data: {{appointment_date}}<br>Horário: {{appointment_time}}<br>Profissional: {{professional_name}}<br>Agenda: {{agenda_name}}<br><br>Por favor, confirme sua presença.'
      },
      {
        name: 'Conflito Detectado - Email',
        type: 'conflict_detected',
        channel: 'email',
        subject: 'Conflitos detectados na agenda {{agenda_name}}',
        body: 'Foram detectados conflitos de horário na agenda {{agenda_name}}.<br><br>Conflitos encontrados: {{conflicts_count}}<br><br>Por favor, acesse o sistema para resolver os conflitos.'
      },
      {
        name: 'Consulta Agendada - Push',
        type: 'appointment_scheduled',
        channel: 'push',
        subject: 'Consulta agendada',
        body: 'Nova consulta agendada para {{appointment_date}} às {{appointment_time}}'
      },
      {
        name: 'Lembrete de Consulta - Push',
        type: 'appointment_reminder',
        channel: 'push',
        subject: 'Lembrete de consulta',
        body: 'Você tem uma consulta {{reminder_type}} em {{agenda_name}}'
      },
      {
        name: 'Alerta de Emergência - Push',
        type: 'emergency_alert',
        channel: 'push',
        subject: 'ALERTA: Consulta de emergência',
        body: 'Consulta de emergência agendada para {{appointment_time}}'
      }
    ]

    default_templates.each do |template_data|
      create!(template_data)
    end
  end
end
