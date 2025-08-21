# frozen_string_literal: true

class Speciality < ApplicationRecord
  include MeiliSearch::Rails

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  has_many :specialization_specialities, dependent: :destroy
  has_many :specializations, through: :specialization_specialities
  has_many :professional_specialities, dependent: :destroy
  has_many :professionals, through: :professional_specialities

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:name) }

  meilisearch do
    searchable_attributes %i[name specialty]
    filterable_attributes %i[active created_at updated_at]
    sortable_attributes %i[created_at updated_at name]

    attribute :name
    attribute :active
    attribute :created_at
    attribute :updated_at
  end
end
