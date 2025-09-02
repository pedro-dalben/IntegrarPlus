# frozen_string_literal: true

class Group < ApplicationRecord
  include DashboardCache
  include MeiliSearch::Rails

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  has_many :professional_groups, dependent: :destroy
  has_many :professionals, through: :professional_groups
  has_many :group_permissions, dependent: :destroy
  has_many :permissions, through: :group_permissions
  has_many :document_permissions, dependent: :destroy

  scope :ordered, -> { order(:name) }
  scope :admin, -> { where(is_admin: true) }

  meilisearch do
    searchable_attributes %i[name description]
    filterable_attributes %i[is_admin created_at updated_at]
    sortable_attributes %i[created_at updated_at name]

    attribute :name
    attribute :description
    attribute :is_admin
    attribute :created_at
    attribute :updated_at
  end

  def admin?
    is_admin?
  end

  def has_permission?(permission_key)
    permissions.exists?(key: permission_key)
  end

  def add_permission(permission_key)
    permission = Permission.find_by(key: permission_key)
    permissions << permission if permission && !has_permission?(permission_key)
  end

  def remove_permission(permission_key)
    permission = permissions.find_by(key: permission_key)
    permissions.delete(permission) if permission
  end

  def users
    User.joins(:professional).where(professional: professionals)
  end
end
