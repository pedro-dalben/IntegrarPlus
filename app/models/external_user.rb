# frozen_string_literal: true

class ExternalUser < ApplicationRecord
  devise_modules = %i[database_authenticatable recoverable validatable]
  devise_modules << :rememberable unless Rails.env.production?
  devise_modules << :timeoutable if Rails.env.production?
  devise(*devise_modules)

  attribute :active, :boolean, default: true

  has_many :service_requests, dependent: :destroy
  has_many :portal_intakes, foreign_key: 'operator_id', dependent: :destroy

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :company_name, presence: true, length: { minimum: 2, maximum: 100 }

  scope :active, -> { where(active: true) }

  def active?
    active
  end

  def full_name
    name.presence || email.split('@').first.titleize
  end
end
