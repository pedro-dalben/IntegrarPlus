# frozen_string_literal: true

class DocumentResponsible < ApplicationRecord
  belongs_to :document
  belongs_to :professional

  enum :status, Document.statuses

  validates :status, presence: true
  validates :document_id, uniqueness: { scope: :status }

  scope :for_status, ->(status) { where(status: status) }
  scope :ordered, -> { order(created_at: :desc) }

  def status_name
    status.humanize
  end

  def status_color
    case status
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
    case status
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
