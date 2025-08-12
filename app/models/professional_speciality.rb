class ProfessionalSpeciality < ApplicationRecord
  belongs_to :professional
  belongs_to :speciality
  
  validates :professional_id, uniqueness: { scope: :speciality_id }
end
