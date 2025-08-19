# frozen_string_literal: true

class Group < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  has_many :memberships, dependent: :destroy
  has_many :professionals, through: :memberships
  has_many :group_permissions, dependent: :destroy
  has_many :permissions, through: :group_permissions

  scope :ordered, -> { order(:name) }
  scope :admin, -> { where(is_admin: true) }
  
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
end
