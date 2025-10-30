# frozen_string_literal: true

class PortalIntake < ApplicationRecord
  include SecurityValidations

  belongs_to :operator, class_name: 'ExternalUser'
  has_many :journey_events, dependent: :destroy
  has_many :portal_intake_referrals, dependent: :destroy, inverse_of: :portal_intake
  has_one :anamnesis, dependent: :destroy

  validates :nome, presence: true, length: { minimum: 2, maximum: 100 }
  validates :plan_name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :card_code, presence: true, length: { minimum: 2, maximum: 50 }
  validates :requested_at, presence: true
  validates :status, presence: true

  # Campos opcionais do ServiceRequest com validações de segurança
  validates :convenio, length: { maximum: 100 }
  validates :carteira_codigo, length: { maximum: 50 }
  validates :telefone_responsavel, length: { maximum: 20 }
  validates :responsavel, length: { maximum: 100 }
  validates :cpf, length: { maximum: 14 }, format: {
    with: /\A\d{3}\.\d{3}\.\d{3}-\d{2}\z/,
    message: 'deve estar no formato 000.000.000-00'
  }, allow_blank: true
  validates :endereco, length: { maximum: 1000 }

  accepts_nested_attributes_for :portal_intake_referrals, allow_destroy: true, reject_if: :all_blank

  after_create :create_initial_journey_event

  def telefone_formatado
    return telefone_responsavel if telefone_responsavel.blank?

    # Remove todos os caracteres não numéricos
    numbers = telefone_responsavel.gsub(/\D/, '')

    # Formata baseado no tamanho
    case numbers.length
    when 10
      numbers.gsub(/(\d{2})(\d{4})(\d{4})/, '(\1) \2-\3')
    when 11
      numbers.gsub(/(\d{2})(\d{5})(\d{4})/, '(\1) \2-\3')
    else
      telefone_responsavel
    end
  end

  def status_badge_class
    case status
    when 'aguardando_agendamento_anamnese'
      'ta-badge ta-badge-warning'
    when 'aguardando_anamnese'
      'ta-badge ta-badge-info'
    when 'anamnese_concluida'
      'ta-badge ta-badge-success'
    else
      'ta-badge ta-badge-secondary'
    end
  end

  def status_label
    case status
    when 'aguardando_agendamento_anamnese'
      'Aguardando Agendamento'
    when 'aguardando_anamnese'
      'Aguardando Anamnese'
    when 'anamnese_concluida'
      'Anamnese Concluída'
    else
      status.humanize
    end
  end

  enum :status, {
    aguardando_agendamento_anamnese: 'aguardando_agendamento_anamnese',
    aguardando_anamnese: 'aguardando_anamnese',
    anamnese_concluida: 'anamnese_concluida'
  }

  scope :by_operator, ->(operator_id) { where(operator_id: operator_id) }
  scope :by_status, ->(status) { where(status: status) }
  scope :requested_between, ->(start_date, end_date) { where(requested_at: start_date..end_date) }
  scope :scheduled_on, ->(date) { where(anamnesis_scheduled_on: date) }
  scope :scheduled_between, ->(start_date, end_date) { where(anamnesis_scheduled_on: start_date..end_date) }
  scope :recent, -> { order(requested_at: :desc) }

  def schedule_anamnesis!(date, admin_user = nil)
    transaction do
      update!(
        anamnesis_scheduled_on: date,
        status: 'aguardando_anamnese'
      )

      journey_events.create!(
        event_type: 'scheduled_anamnesis',
        metadata: {
          admin_id: admin_user&.id,
          admin_name: admin_user&.full_name,
          ip: nil,
          from: 'aguardando_agendamento_anamnese',
          to: 'aguardando_anamnese',
          scheduled_on: date
        }
      )
    end
  end

  def finish_anamnesis!(admin_user = nil)
    transaction do
      update!(status: 'anamnese_concluida')

      journey_events.create!(
        event_type: 'finished_anamnesis',
        metadata: {
          admin_id: admin_user&.id,
          admin_name: admin_user&.full_name,
          ip: nil,
          from: 'aguardando_anamnese',
          to: 'anamnese_concluida'
        }
      )
    end
  end

  def can_schedule_anamnesis?
    aguardando_agendamento_anamnese?
  end

  def can_finish_anamnesis?
    aguardando_anamnese?
  end

  def can_reschedule_anamnesis?
    aguardando_anamnese? && anamnesis_scheduled_on.present?
  end

  def reschedule_anamnesis!(new_date, admin_user = nil, reason = nil)
    return false unless can_reschedule_anamnesis?

    transaction do
      old_date = anamnesis_scheduled_on

      update!(
        anamnesis_scheduled_on: new_date
      )

      journey_events.create!(
        event_type: 'rescheduled_anamnesis',
        metadata: {
          admin_id: admin_user&.id,
          admin_name: admin_user&.full_name,
          ip: nil,
          old_scheduled_on: old_date,
          new_scheduled_on: new_date,
          reason: reason
        }
      )

      if anamnesis.present?
        if anamnesis.medical_appointment.present?
          old_appointment = anamnesis.medical_appointment

          old_appointment.update!(
            status: 'cancelled',
            cancellation_reason: "Reagendado - #{reason}",
            cancelled_at: Time.current
          )

          old_appointment.event.update!(status: 'cancelled') if old_appointment.event.present?
        end

        anamnesis.update!(performed_at: new_date)
      end
    end

    true
  end

  def can_cancel_anamnesis?
    aguardando_anamnese? && anamnesis_scheduled_on.present?
  end

  def cancel_anamnesis!(admin_user = nil, reason = nil)
    return false unless can_cancel_anamnesis?

    transaction do
      old_date = anamnesis_scheduled_on

      update!(
        anamnesis_scheduled_on: nil,
        status: 'aguardando_agendamento_anamnese'
      )

      journey_events.create!(
        event_type: 'cancelled_anamnesis',
        metadata: {
          admin_id: admin_user&.id,
          admin_name: admin_user&.full_name,
          ip: nil,
          cancelled_scheduled_on: old_date,
          reason: reason,
          from: 'aguardando_anamnese',
          to: 'aguardando_agendamento_anamnese'
        }
      )

      if anamnesis.present?
        medical_appointments = MedicalAppointment.where(anamnesis_id: anamnesis.id)
        medical_appointments.each do |appointment|
          appointment.update!(
            status: 'cancelled',
            cancellation_reason: reason,
            cancelled_at: Time.current,
            anamnesis_id: nil
          )

          appointment.event.update!(status: 'cancelled') if appointment.event.present?
        end

        anamnesis.destroy
      end
    end

    true
  end

  private

  def all_blank(attributes)
    attributes['cid'].blank? && attributes['encaminhado_para'].blank? && attributes['medico'].blank?
  end

  def create_initial_journey_event
    journey_events.create!(
      event_type: 'created',
      metadata: {
        operator_id: operator_id,
        operator_name: operator.full_name,
        initial_status: status
      }
    )
  end
end
