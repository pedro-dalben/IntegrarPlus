# frozen_string_literal: true

class PortalIntakeReferral < ApplicationRecord
  include SecurityValidations

  belongs_to :portal_intake

  ENCAMINHAMENTO_OPTIONS = %w[
    ABA
    FONO
    TO
    PSICOPEDAGOGIA
    PSICOLOGIA
    PSICOMOTRICIDADE
    FISIOTERAPIA
    EQUOTERAPIA
    MUSICOTERAPIA
  ].freeze

  validates :cid, presence: true, length: { maximum: 20 }, format: {
    with: /\A[A-Z]\d{2}\.\d{1,2}\z/,
    message: 'deve estar no formato A00.0 (ex: F84.0)',
    allow_blank: false
  }
  validates :encaminhado_para, presence: true, inclusion: { in: ENCAMINHAMENTO_OPTIONS }
  validates :medico, presence: true, length: { minimum: 2, maximum: 100 }
  validates :medico_crm, presence: true, length: { minimum: 4, maximum: 20 }, format: {
    with: /\A\d{4,6}\z/,
    message: 'deve conter apenas números com 4 a 6 dígitos',
    allow_blank: false
  }
  validates :data_encaminhamento, presence: true
  validates :descricao, length: { maximum: 1000 }

  scope :by_tipo, ->(tipo) { where(encaminhado_para: tipo) if tipo.present? }
end
