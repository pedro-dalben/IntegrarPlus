# frozen_string_literal: true

class PortalIntakeReferral < ApplicationRecord
  include SecurityValidations

  belongs_to :portal_intake, inverse_of: :portal_intake_referrals

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

  validates :cid, length: { maximum: 20 }, format: {
    with: /\A[A-Z]\d{2}\.\d{1,2}\z/,
    message: 'deve estar no formato A00.0 (ex: F84.0)',
    allow_blank: true
  }, if: :any_field_present?
  validates :encaminhado_para, inclusion: { in: ENCAMINHAMENTO_OPTIONS }, allow_blank: true, if: :any_field_present?
  validates :medico, length: { minimum: 2, maximum: 100 }, allow_blank: true, if: :any_field_present?
  validates :medico_crm, length: { minimum: 4, maximum: 20 }, format: {
    with: /\A\d{4,6}\z/,
    message: 'deve conter apenas números com 4 a 6 dígitos',
    allow_blank: true
  }, if: :any_field_present?
  validates :data_encaminhamento, presence: true, if: :any_field_present?
  validates :descricao, length: { maximum: 1000 }

  scope :by_tipo, ->(tipo) { where(encaminhado_para: tipo) if tipo.present? }

  private

  def any_field_present?
    cid.present? || encaminhado_para.present? || medico.present? || medico_crm.present? || data_encaminhamento.present? || descricao.present?
  end
end
