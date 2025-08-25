# frozen_string_literal: true

class Permission < ApplicationRecord
  validates :key, presence: true, uniqueness: { case_sensitive: false }

  has_many :group_permissions, dependent: :destroy
  has_many :groups, through: :group_permissions

  scope :ordered, -> { order(:key) }

  def self.by_key(key)
    find_by(key: key)
  end

  def self.exists?(key)
    exists?(key: key)
  end
end
