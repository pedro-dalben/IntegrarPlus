# frozen_string_literal: true

class PortalIntake < ApplicationRecord
  belongs_to :operator, class_name: 'ExternalUser', foreign_key: 'operator_id'
  has_many :journey_events, dependent: :destroy

  validates :beneficiary_name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :plan_name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :card_code, presence: true, length: { minimum: 2, maximum: 50 }
  validates :requested_at, presence: true
  validates :status, presence: true

  after_create :create_initial_journey_event

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

  private

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
