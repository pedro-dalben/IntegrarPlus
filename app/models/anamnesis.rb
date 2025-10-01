# frozen_string_literal: true

class Anamnesis < ApplicationRecord
  include MeiliSearch::Rails unless Rails.env.test?

  # Relacionamentos
  belongs_to :beneficiary
  belongs_to :professional, class_name: 'User'
  belongs_to :portal_intake, optional: true
  belongs_to :created_by_professional, class_name: 'User', optional: true
  belongs_to :updated_by_professional, class_name: 'User', optional: true
  has_one :medical_appointment, dependent: :nullify

  # Enums
  enum :status, {
    pendente: 'pendente',
    em_andamento: 'em_andamento',
    concluida: 'concluida'
  }

  enum :referral_reason, {
    aba: 'aba',
    equipe_multi: 'equipe_multi',
    aba_equipe_multi: 'aba_equipe_multi'
  }

  enum :treatment_location, {
    domiciliar: 'domiciliar',
    clinica: 'clinica',
    domiciliar_clinica: 'domiciliar_clinica',
    domiciliar_escola: 'domiciliar_escola',
    domiciliar_clinica_escola: 'domiciliar_clinica_escola',
    domiciliar_escola: 'domiciliar_escola'
  }

  enum :school_period, {
    manha: 'manha',
    tarde: 'tarde'
  }

  # Validações
  validates :performed_at, presence: true
  validates :status, presence: true
  validates :referral_reason, presence: true
  validates :treatment_location, presence: true
  validates :referral_hours, presence: true,
                             numericality: { in: 5..40, message: 'deve estar entre 5 e 40 horas' }

  # Validações condicionais
  validates :school_name, presence: true, if: :attends_school?
  validates :school_period, presence: true, if: :attends_school?

  # Callbacks
  before_validation :set_default_values
  after_create :create_beneficiary_from_portal_intake, if: :portal_intake_id?

  # Scopes
  scope :by_professional, ->(professional) { where(professional: professional) }
  scope :by_beneficiary, ->(beneficiary) { where(beneficiary: beneficiary) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_date_range, ->(start_date, end_date) { where(performed_at: start_date..end_date) }
  scope :today, -> { where(performed_at: Date.current.all_day) }
  scope :this_week, -> { where(performed_at: Date.current.all_week) }
  scope :this_month, -> { where(performed_at: Date.current.all_month) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_date, -> { order(performed_at: :desc) }

  # MeiliSearch configuration
  unless Rails.env.test?
    meilisearch do
      searchable_attributes %i[beneficiary_name professional_name referral_reason]
      filterable_attributes %i[status performed_at professional_id]
      sortable_attributes %i[created_at updated_at performed_at]

      attribute :beneficiary_name do
        beneficiary.name
      end
      attribute :professional_name do
        professional.full_name
      end
      attribute :performed_at
      attribute :status
      attribute :referral_reason
      attribute :created_at
      attribute :updated_at
    end
  end

  # Métodos de instância
  delegate :name, to: :beneficiary, prefix: true

  def professional_name
    professional.full_name
  end

  def status_badge_class
    case status
    when 'pendente'
      'ta-badge ta-badge-warning'
    when 'em_andamento'
      'ta-badge ta-badge-info'
    when 'concluida'
      'ta-badge ta-badge-success'
    else
      'ta-badge ta-badge-secondary'
    end
  end

  def status_label
    case status
    when 'pendente'
      'Pendente'
    when 'em_andamento'
      'Em Andamento'
    when 'concluida'
      'Concluída'
    else
      status.humanize
    end
  end

  def referral_reason_label
    case referral_reason
    when 'aba'
      'ABA'
    when 'equipe_multi'
      'Equipe Multi'
    when 'aba_equipe_multi'
      'ABA + Equipe Multi'
    else
      referral_reason.humanize
    end
  end

  def treatment_location_label
    case treatment_location
    when 'domiciliar'
      'Domiciliar'
    when 'clinica'
      'Clínica'
    when 'domiciliar_clinica'
      'Domiciliar + Clínica'
    when 'domiciliar_escola'
      'Domiciliar + Escola'
    when 'domiciliar_clinica_escola'
      'Domiciliar + Clínica + Escola'
    else
      treatment_location.humanize
    end
  end

  def pode_ser_editada?
    pendente? || em_andamento?
  end

  def pode_ser_concluida?
    em_andamento?
  end

  def pode_ser_iniciada?
    pendente?
  end

  def iniciar!(professional)
    return false unless pode_ser_iniciada?

    update!(
      status: 'em_andamento',
      updated_by_professional: professional
    )
  end

  def concluir!(professional)
    return false unless pode_ser_concluida?

    transaction do
      update!(
        status: 'concluida',
        updated_by_professional: professional
      )

      # Criar beneficiário se veio do portal
      create_beneficiary_from_portal_intake if portal_intake_id?
    end
  end

  def specialties_array
    return [] if specialties.blank?

    specialties.is_a?(Array) ? specialties : JSON.parse(specialties)
  rescue JSON::ParserError
    []
  end

  def previous_treatments_array
    return [] if previous_treatments.blank?

    previous_treatments.is_a?(Array) ? previous_treatments : JSON.parse(previous_treatments)
  rescue JSON::ParserError
    []
  end

  def external_treatments_array
    return [] if external_treatments.blank?

    external_treatments.is_a?(Array) ? external_treatments : JSON.parse(external_treatments)
  rescue JSON::ParserError
    []
  end

  def preferred_schedule_array
    return [] if preferred_schedule.blank?

    preferred_schedule.is_a?(Array) ? preferred_schedule : JSON.parse(preferred_schedule)
  rescue JSON::ParserError
    []
  end

  def unavailable_schedule_array
    return [] if unavailable_schedule.blank?

    unavailable_schedule.is_a?(Array) ? unavailable_schedule : JSON.parse(unavailable_schedule)
  rescue JSON::ParserError
    []
  end

  # Métodos de classe
  def self.by_professional_today(professional)
    by_professional(professional).today
  end

  def self.by_professional_week(professional)
    by_professional(professional).this_week
  end

  def self.pendentes
    where(status: 'pendente')
  end

  def self.em_andamento
    where(status: 'em_andamento')
  end

  def self.concluidas
    where(status: 'concluida')
  end

  def self.search_by_term(term)
    return all if term.blank?

    joins(:beneficiary, :professional).where(
      'beneficiaries.name ILIKE ? OR users.full_name ILIKE ? OR anamneses.referral_reason ILIKE ?',
      "%#{term}%", "%#{term}%", "%#{term}%"
    )
  end

  private

  def set_default_values
    self.performed_at ||= Time.current
    self.created_by_professional ||= professional
  end

  def create_beneficiary_from_portal_intake
    return unless portal_intake_id? && beneficiary.nil?

    # Criar beneficiário a partir dos dados do portal intake
    beneficiary_data = {
      name: portal_intake.nome || portal_intake.beneficiary_name,
      birth_date: portal_intake.data_nascimento,
      cpf: portal_intake.cpf,
      phone: portal_intake.telefone_responsavel,
      address: portal_intake.endereco,
      responsible_name: portal_intake.responsavel,
      responsible_phone: portal_intake.telefone_responsavel,
      health_plan: portal_intake.plan_name,
      health_card_number: portal_intake.card_code,
      status: 'ativo',
      treatment_start_date: Date.current,
      created_by_professional: professional,
      portal_intake: portal_intake
    }

    new_beneficiary = Beneficiary.create!(beneficiary_data)
    update!(beneficiary: new_beneficiary)
  end
end
