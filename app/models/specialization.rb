# frozen_string_literal: true

class Specialization < ApplicationRecord
  include DashboardCache
  include MeiliSearch::Rails

  has_many :specialization_specialities, dependent: :destroy
  has_many :specialities, through: :specialization_specialities

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  has_many :professional_specializations, dependent: :destroy
  has_many :professionals, through: :professional_specializations

  scope :ordered, -> { order(:name) }
  scope :by_speciality, ->(speciality_ids) { joins(:specialities).where(specialities: { id: speciality_ids }) }

  meilisearch do
    searchable_attributes %i[name]
    filterable_attributes %i[created_at updated_at]
    sortable_attributes %i[created_at updated_at name]

    attribute :name
    attribute :created_at
    attribute :updated_at
  end
end
