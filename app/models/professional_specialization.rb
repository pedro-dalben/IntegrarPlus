class ProfessionalSpecialization < ApplicationRecord
  belongs_to :professional
  belongs_to :specialization
  
  validates :professional_id, uniqueness: { scope: :specialization_id }
end
