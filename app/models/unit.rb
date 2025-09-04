class Unit < ApplicationRecord
  has_many :agendas, dependent: :nullify

  validates :name, presence: true, uniqueness: true
end
