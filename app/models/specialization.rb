# frozen_string_literal: true

class Specialization < ApplicationRecord
  include MeiliSearch::Rails

  belongs_to :speciality

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  has_many :professional_specializations, dependent: :destroy
  has_many :professionals, through: :professional_specializations

  scope :ordered, -> { order(:name) }
  scope :by_speciality, ->(speciality_ids) { where(speciality_id: speciality_ids) }

  meilisearch do
    searchable_attributes %i[name]
    filterable_attributes %i[speciality_id created_at updated_at]
    sortable_attributes %i[created_at updated_at name]
  end
end
