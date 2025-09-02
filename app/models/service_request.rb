# frozen_string_literal: true

class ServiceRequest < ApplicationRecord
  belongs_to :external_user
  has_many :service_request_referrals, dependent: :destroy

  validates :convenio, presence: true, length: { maximum: 100 }
  validates :carteira_codigo, presence: true, length: { maximum: 50 }
  validates :nome, presence: true, length: { minimum: 2, maximum: 100 }
  validates :telefone_responsavel, presence: true, length: { maximum: 20 }
  validates :data_encaminhamento, presence: true
  validates :status, presence: true, inclusion: { in: %w[aguardando processado] }

  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :by_date_range, lambda { |start_date, end_date|
    where(data_encaminhamento: start_date..end_date) if start_date.present? && end_date.present?
  }
  scope :recent, -> { order(data_encaminhamento: :desc) }

  accepts_nested_attributes_for :service_request_referrals, allow_destroy: true, reject_if: :all_blank

  def status_humanizado
    case status
    when 'aguardando'
      'Aguardando'
    when 'processado'
      'Processado'
    else
      status.humanize
    end
  end

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

  private

  def all_blank(attributes)
    attributes['cid'].blank? && attributes['encaminhado_para'].blank? && attributes['medico'].blank?
  end
end
