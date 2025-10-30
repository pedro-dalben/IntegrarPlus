# frozen_string_literal: true

class FlowChart < ApplicationRecord
  belongs_to :created_by, class_name: 'Professional'
  belongs_to :updated_by, class_name: 'Professional', optional: true
  belongs_to :current_version, class_name: 'FlowChartVersion', optional: true

  has_many :versions, class_name: 'FlowChartVersion', dependent: :destroy
  has_one_attached :thumbnail

  enum :status, { draft: 0, published: 1, archived: 2 }

  validates :title, presence: true, length: { minimum: 2, maximum: 255 }
  validate :must_have_current_version_to_publish

  scope :ordered, -> { order(updated_at: :desc) }
  scope :recent, -> { ordered.limit(10) }

  def can_publish?
    current_version.present?
  end

  def publish!
    raise 'Cannot publish without a current version' unless can_publish?

    update!(status: :published)
  end

  def duplicate
    new_chart = dup
    new_chart.title = "#{title} (cópia)"
    new_chart.status = :draft
    new_chart.current_version = nil

    if save && current_version.present?
      new_version = current_version.dup
      new_version.flow_chart = new_chart
      new_version.version = 1
      new_version.notes = 'Versão inicial (duplicada)'
      new_version.save!

      new_chart.update!(current_version: new_version)
    end

    new_chart
  end

  def latest_version
    versions.order(version: :desc).first
  end

  def version_number
    current_version&.version || 0
  end

  private

  def must_have_current_version_to_publish
    return unless published? && current_version.blank?

    errors.add(:base, 'Não é possível publicar sem uma versão ativa')
  end
end
