class ProfessionalGroup < ApplicationRecord
  belongs_to :professional
  belongs_to :group

  validates :professional_id, uniqueness: { scope: :group_id }
end
