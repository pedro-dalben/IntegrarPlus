# frozen_string_literal: true

class Professional < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable

  belongs_to :contract_type, optional: true

  has_many :memberships, dependent: :destroy
  has_many :groups, through: :memberships
  has_many :professional_specialities, dependent: :destroy
  has_many :specialities, through: :professional_specialities
  has_many :professional_specializations, dependent: :destroy
  has_many :specializations, through: :professional_specializations

  validates :full_name, presence: true
  validates :cpf, presence: true, uniqueness: { case_sensitive: false }, cpf: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :phone, phone: true, allow_blank: true
  validates :cnpj, cnpj: true, allow_blank: true
  validates :workload_minutes, numericality: { greater_than_or_equal_to: 0 }
  validates :birth_date, date: { after: Date.new(1900, 1, 1), before_or_equal_to: Date.current }, allow_blank: true

  validate :contract_type_consistency
  validate :specialization_consistency

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:full_name) }

  def active_for_authentication?
    super && active?
  end

  def inactive_message
    active? ? super : :not_approved
  end

  def workload_hours
    return 0 if workload_minutes.nil?

    (workload_minutes / 60.0).round(2)
  end

  def workload_hours=(hours)
    self.workload_minutes = (hours.to_f * 60).round
  end

  def workload_hhmm
    return '00:00' if workload_minutes.nil?

    hours = workload_minutes / 60
    minutes = workload_minutes % 60
    format('%02d:%02d', hours, minutes)
  end

  def workload_hhmm=(hhmm)
    return if hhmm.blank?

    hours, minutes = hhmm.split(':').map(&:to_i)
    self.workload_minutes = (hours * 60) + minutes
  end

  private

  def contract_type_consistency
    return unless contract_type

    if contract_type.requires_company? && company_name.blank?
      errors.add(:company_name, 'é obrigatório para este tipo de contratação')
    end

    return unless contract_type.requires_cnpj? && cnpj.blank?

    errors.add(:cnpj, 'é obrigatório para este tipo de contratação')
  end

  def specialization_consistency
    return if specializations.empty? || specialities.empty?

    invalid_specializations = specializations.reject do |spec|
      specialities.include?(spec.speciality)
    end

    return unless invalid_specializations.any?

    errors.add(:specializations, 'contém especializações que não pertencem às especialidades selecionadas')
  end
end
