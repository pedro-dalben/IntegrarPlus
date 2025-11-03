# frozen_string_literal: true

class Beneficiary < ApplicationRecord
  include MeiliSearch::Rails unless Rails.env.test?

  # Relacionamentos
  belongs_to :portal_intake, optional: true
  belongs_to :created_by_professional, class_name: 'User', optional: true
  belongs_to :updated_by_professional, class_name: 'User', optional: true
  has_many :anamneses, class_name: 'Anamnesis', dependent: :destroy
  has_many :beneficiary_professionals, dependent: :destroy
  has_many :professionals, through: :beneficiary_professionals
  has_many :beneficiary_tickets, dependent: :destroy

  # Enums
  enum :status, {
    ativo: 'ativo',
    inativo: 'inativo',
    suspenso: 'suspenso',
    transferido: 'transferido'
  }

  enum :school_period, {
    manha: 'manha',
    tarde: 'tarde',
    integral: 'integral'
  }

  # Validações
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :birth_date, presence: true
  validates :cpf, presence: true, uniqueness: { case_sensitive: false }
  validates :integrar_code, presence: true, uniqueness: { case_sensitive: false }
  validates :status, presence: true

  # Validações condicionais
  validates :school_name, presence: true, if: :attends_school?
  validates :school_period, presence: true, if: :attends_school?

  # Validações de formato
  validates :cpf, format: { with: /\A\d{3}\.\d{3}\.\d{3}-\d{2}\z/, message: 'deve estar no formato 000.000.000-00' }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :secondary_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :zip_code, format: { with: /\A\d{5}-?\d{3}\z/, message: 'deve estar no formato 00000-000' },
                       allow_blank: true

  # Callbacks
  before_validation :generate_integrar_code, on: :create
  before_validation :format_cpf
  before_validation :format_zip_code

  # Scopes
  scope :active, -> { where(status: 'ativo') }
  scope :inactive, -> { where(status: %w[inativo suspenso transferido]) }
  scope :by_name, ->(name) { where('name ILIKE ?', "%#{name}%") }
  scope :by_cpf, ->(cpf) { where(cpf: cpf) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_age_range, lambda { |min_age, max_age|
    where(birth_date: max_age.years.ago..min_age.years.ago)
  }
  scope :recent, -> { order(created_at: :desc) }
  scope :ordered, -> { order(:name) }

  # MeiliSearch configuration
  unless Rails.env.test?
    meilisearch do
      searchable_attributes %i[name cpf integrar_code responsible_name]
      filterable_attributes %i[status birth_date created_at]
      sortable_attributes %i[created_at updated_at name birth_date]

      attribute :name
      attribute :cpf
      attribute :integrar_code
      attribute :birth_date
      attribute :status
      attribute :responsible_name
      attribute :created_at
      attribute :updated_at
    end
  end

  # Métodos de instância
  def age
    return nil unless birth_date

    today = Date.current
    age = today.year - birth_date.year
    age -= 1 if today < Date.new(today.year, birth_date.month, birth_date.day)
    age
  end

  def full_name
    name
  end

  def formatted_phone
    return phone if phone.blank?

    numbers = phone.gsub(/\D/, '')
    case numbers.length
    when 10
      numbers.gsub(/(\d{2})(\d{4})(\d{4})/, '(\1) \2-\3')
    when 11
      numbers.gsub(/(\d{2})(\d{5})(\d{4})/, '(\1) \2-\3')
    else
      phone
    end
  end

  def formatted_responsible_phone
    return responsible_phone if responsible_phone.blank?

    numbers = responsible_phone.gsub(/\D/, '')
    case numbers.length
    when 10
      numbers.gsub(/(\d{2})(\d{4})(\d{4})/, '(\1) \2-\3')
    when 11
      numbers.gsub(/(\d{2})(\d{5})(\d{4})/, '(\1) \2-\3')
    else
      responsible_phone
    end
  end

  def full_address
    parts = [address, address_number, address_complement, neighborhood, city, state, zip_code].compact
    parts.join(', ')
  end

  def status_badge_class
    case status
    when 'ativo'
      'ta-badge ta-badge-success'
    when 'inativo'
      'ta-badge ta-badge-secondary'
    when 'suspenso'
      'ta-badge ta-badge-warning'
    when 'transferido'
      'ta-badge ta-badge-info'
    else
      'ta-badge ta-badge-secondary'
    end
  end

  def status_label
    case status
    when 'ativo'
      'Ativo'
    when 'inativo'
      'Inativo'
    when 'suspenso'
      'Suspenso'
    when 'transferido'
      'Transferido'
    else
      status.humanize
    end
  end

  def pode_ser_editado?
    ativo?
  end

  def pode_ser_excluido?
    anamneses.empty? && medical_appointments.empty?
  end

  def anamnese_pendente?
    anamneses.exists?(status: %w[pendente em_andamento])
  end

  def ultima_anamnese
    anamneses.order(created_at: :desc).first
  end

  # Métodos de classe
  def self.generate_next_integrar_code
    last_number = where('integrar_code LIKE ?', 'CI%')
                  .pluck(:integrar_code)
                  .map { |ci| ci.gsub('CI', '').to_i }
                  .max || 0

    "CI#{(last_number + 1).to_s.rjust(5, '0')}"
  end

  def self.by_age(age)
    where(birth_date: age.years.ago.all_year)
  end

  def self.search_by_term(term)
    return all if term.blank?

    where(
      'name ILIKE ? OR cpf ILIKE ? OR integrar_code ILIKE ? OR responsible_name ILIKE ?',
      "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%"
    )
  end

  private

  def generate_integrar_code
    return if integrar_code.present?

    self.integrar_code = self.class.generate_next_integrar_code
  end

  def format_cpf
    return if cpf.blank?

    # Remove caracteres não numéricos
    numbers = cpf.gsub(/\D/, '')

    # Aplica máscara se tiver 11 dígitos
    return unless numbers.length == 11

    self.cpf = numbers.gsub(/(\d{3})(\d{3})(\d{3})(\d{2})/, '\1.\2.\3-\4')
  end

  def format_zip_code
    return if zip_code.blank?

    # Remove caracteres não numéricos
    numbers = zip_code.gsub(/\D/, '')

    # Aplica máscara se tiver 8 dígitos
    return unless numbers.length == 8

    self.zip_code = numbers.gsub(/(\d{5})(\d{3})/, '\1-\2')
  end
end
