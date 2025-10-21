class FlowChartVersion < ApplicationRecord
  belongs_to :flow_chart
  belongs_to :created_by, class_name: 'Professional', foreign_key: :created_by_id

  enum :data_format, { xml: 0, svg: 1 }

  validates :version, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :data, presence: true
  validates :data_format, presence: true

  scope :ordered, -> { order(version: :desc) }
  scope :recent, -> { ordered.limit(5) }

  before_validation :set_version_number, on: :create

  def display_name
    "Versão #{version}"
  end

  def has_notes?
    notes.present?
  end

  private

  def set_version_number
    return if version.present?

    max_version = flow_chart.versions.maximum(:version) || 0
    self.version = max_version + 1
  end
end
