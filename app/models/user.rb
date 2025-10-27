# frozen_string_literal: true

class User < ApplicationRecord
  include DashboardCache

  devise_modules = %i[database_authenticatable registerable recoverable validatable]
  devise_modules << :rememberable unless Rails.env.production?
  devise_modules << :timeoutable if Rails.env.production?
  devise(*devise_modules)

  belongs_to :professional
  has_one_attached :avatar
  has_many :invites, dependent: :destroy
  has_many :document_permissions, dependent: :destroy
  has_many :document_status_changes, dependent: :destroy
  has_many :version_comments, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :notification_preferences, dependent: :destroy

  validates :professional, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }

  validate :professional_must_be_active, on: :create

  delegate :full_name, :groups, :permit?, :admin?, to: :professional, allow_nil: true

  scope :professionals, -> { joins(:professional) }
  scope :active, -> { joins(:professional).where(professionals: { active: true }) }

  def name
    professional&.full_name || email.split('@').first.titleize
  end

  def professional_full_name
    full_name
  end

  def pending_invite?
    invites.pending.exists?
  end

  def confirmed_invite?
    invites.confirmed.exists?
  end

  def latest_invite
    invites.order(created_at: :desc).first
  end

  private

  def professional_must_be_active
    return if professional&.active?
    errors.add(:professional, 'deve estar ativo para criar um usuário')
  end
end
