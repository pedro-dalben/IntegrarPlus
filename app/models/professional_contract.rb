class ProfessionalContract < ApplicationRecord
  belongs_to :professional
  belongs_to :job_role, required: false

  enum :contract_type_enum, {
    pj: 'pj',
    autonomo: 'autonomo'
  }

  enum :payment_type, {
    fechado: 'fechado',
    por_hora: 'por_hora'
  }

  validates :contract_type_enum, presence: true
  validates :payment_type, presence: true

  validates :monthly_value, presence: true, if: -> { payment_type == 'fechado' }
  validates :hourly_value, presence: true, if: -> { payment_type == 'por_hora' }

  validates :company_cnpj, presence: true, if: -> { contract_type_enum == 'pj' }
  validates :company_address, presence: true, if: -> { contract_type_enum == 'pj' }
  validates :company_represented_by, presence: true, if: -> { contract_type_enum == 'pj' }

  validates :ccm, presence: true, if: -> { contract_type_enum == 'autonomo' }
  validates :taxpayer_address, presence: true, if: -> { contract_type_enum == 'autonomo' }

  def pj?
    contract_type_enum == 'pj'
  end

  def autonomo?
    contract_type_enum == 'autonomo'
  end

  def fechado?
    payment_type == 'fechado'
  end

  def por_hora?
    payment_type == 'por_hora'
  end

  def has_overtime_value?
    overtime_hour_value.present? && overtime_hour_value > 0
  end
end

