# frozen_string_literal: true

class Speciality < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  has_many :specializations, dependent: :destroy
  has_many :professional_specialities, dependent: :destroy
  has_many :professionals, through: :professional_specialities

  scope :ordered, -> { order(:name) }
end
