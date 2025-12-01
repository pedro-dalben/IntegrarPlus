class JobRole < ApplicationRecord
  has_many :professional_contracts, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :description, presence: true

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:name) }
end

