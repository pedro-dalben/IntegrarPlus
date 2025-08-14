# frozen_string_literal: true

class Membership < ApplicationRecord
  belongs_to :professional
  belongs_to :group

  validates :professional_id, uniqueness: { scope: :group_id }
end
