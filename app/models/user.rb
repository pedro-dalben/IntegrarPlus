# frozen_string_literal: true

class User < ApplicationRecord
  include DashboardCache

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :avatar
  has_one :professional, dependent: :nullify
  has_many :invites, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :groups, through: :memberships
  has_many :documents, foreign_key: :author_id, dependent: :destroy
  has_many :document_versions, foreign_key: :created_by_id, dependent: :destroy
  has_many :document_permissions, dependent: :destroy
  has_many :version_comments, dependent: :destroy

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }

  def full_name
    name.presence || email.split('@').first.titleize
  end

  def permit?(permission_key)
    return true if admin?

    groups.any? { |group| group.has_permission?(permission_key) }
  end

  def admin?
    groups.any?(&:admin?)
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
