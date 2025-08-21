# frozen_string_literal: true

class SpecializationSpeciality < ApplicationRecord
  belongs_to :specialization
  belongs_to :speciality

  validates :specialization_id, uniqueness: { scope: :speciality_id }
end
