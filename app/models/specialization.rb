class Specialization < ApplicationRecord
  belongs_to :speciality
  
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :speciality, presence: true

  has_many :professional_specializations, dependent: :destroy
  has_many :professionals, through: :professional_specializations

  scope :ordered, -> { order(:name) }
  scope :by_speciality, ->(speciality_ids) { where(speciality_id: speciality_ids) }
end
