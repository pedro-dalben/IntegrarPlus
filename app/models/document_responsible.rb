# frozen_string_literal: true

class DocumentResponsible < ApplicationRecord
  belongs_to :document
  belongs_to :professional

  enum :status, Document.statuses

  validates :status, presence: true
  validates :professional, presence: true
  validates :document_id, uniqueness: { scope: :status }

  scope :for_status, ->(status) { where(status: status) }
  scope :ordered, -> { order(created_at: :desc) }

  def status_name
    status.humanize
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
