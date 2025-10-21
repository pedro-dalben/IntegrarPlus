# frozen_string_literal: true

class AgendaProfessional < ApplicationRecord
  belongs_to :agenda
  belongs_to :professional, class_name: 'User'

  validates :capacity_per_slot, presence: true, numericality: { greater_than: 0 }
  validates :professional_id, uniqueness: { scope: :agenda_id, message: 'já está vinculado a esta agenda' }

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  def professional_name
    professional&.name || 'Profissional não encontrado'
  end

  def professional_specialties
    professional&.professional&.specialities&.pluck(:name)&.join(', ') || 'Sem especialidades'
  end
end
