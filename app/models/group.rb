class Group < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  
  has_many :memberships, dependent: :destroy
  has_many :professionals, through: :memberships

  scope :ordered, -> { order(:name) }
end
