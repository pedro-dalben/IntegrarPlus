# frozen_string_literal: true

class ExternalUser < ApplicationRecord
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  has_many :service_requests, dependent: :destroy

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :company_name, presence: true, length: { minimum: 2, maximum: 100 }

  scope :active, -> { where(active: true) }

  def full_name
    name.presence || email.split('@').first.titleize
  end
end
