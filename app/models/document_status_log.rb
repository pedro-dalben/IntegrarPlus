# frozen_string_literal: true

class DocumentStatusLog < ApplicationRecord
  belongs_to :document
  belongs_to :professional

  enum :old_status, Document.statuses, prefix: :old
  enum :new_status, Document.statuses, prefix: :new

  validates :old_status, presence: true
  validates :new_status, presence: true

  scope :ordered, -> { order(created_at: :desc) }

  def status_change_description
    case new_status
    when 'aguardando_revisao'
      'Documento enviado para revisão'
    when 'aguardando_correcoes'
      'Correções solicitadas'
    when 'aguardando_liberacao'
      'Documento aprovado, aguardando liberação'
    when 'liberado'
      'Documento liberado como versão final'
    else
      "Status alterado para #{new_status.humanize}"
    end
  end

  def status_color
    case new_status
    when 'aguardando_revisao'
      'text-yellow-600 bg-yellow-50 border-yellow-200'
    when 'aguardando_correcoes'
      'text-red-600 bg-red-50 border-red-200'
    when 'aguardando_liberacao'
      'text-orange-600 bg-orange-50 border-orange-200'
    when 'liberado'
      'text-green-600 bg-green-50 border-green-200'
    end
  end

  def status_icon
    case new_status
    when 'aguardando_revisao'
      '🔍'
    when 'aguardando_correcoes'
      '⚠️'
    when 'aguardando_liberacao'
      '⏳'
    when 'liberado'
      '✅'
    end
  end
end
