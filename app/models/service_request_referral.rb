# frozen_string_literal: true

class ServiceRequestReferral < ApplicationRecord
  belongs_to :service_request

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

  validates :cid, presence: true, length: { maximum: 20 }
  validates :encaminhado_para, presence: true, inclusion: { in: ENCAMINHAMENTO_OPTIONS }
  validates :medico, presence: true, length: { minimum: 2, maximum: 100 }
  validates :medico_crm, presence: true, length: { minimum: 4, maximum: 20 }
  validates :data_encaminhamento, presence: true
  validates :descricao, length: { maximum: 1000 }

  scope :by_tipo, ->(tipo) { where(encaminhado_para: tipo) if tipo.present? }
end
