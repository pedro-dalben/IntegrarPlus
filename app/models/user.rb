# frozen_string_literal: true

class User < ApplicationRecord
  include DashboardCache

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :professional
  has_one_attached :avatar
  has_many :invites, dependent: :destroy
  has_many :document_permissions, dependent: :destroy
  has_many :document_status_changes, dependent: :destroy
  has_many :version_comments, dependent: :destroy

  delegate :full_name, :groups, :permit?, :admin?, to: :professional, allow_nil: true

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
end
