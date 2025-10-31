# frozen_string_literal: true

class BeneficiaryProfessional < ApplicationRecord
  belongs_to :beneficiary
  belongs_to :professional
end
