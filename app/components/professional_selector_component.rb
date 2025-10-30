# frozen_string_literal: true

class ProfessionalSelectorComponent < ViewComponent::Base
  def initialize(selected_professionals: [], multiple: true, searchable: true, agenda: nil)
    @selected_professionals = selected_professionals
    @multiple = multiple
    @searchable = searchable
    @agenda = agenda
  end

  private

  attr_reader :selected_professionals, :multiple, :searchable, :agenda

  def multiple?
    @multiple
  end

  def searchable?
    @searchable
  end

  def selected_professional_ids
    selected_professionals.map { |p| p.respond_to?(:user) && p.user.present? ? p.user.id : p.id }
  end

  def component_id
    "professional-selector-#{SecureRandom.hex(4)}"
  end

  def professional_id_of(record)
    record.respond_to?(:user) && record.user.present? ? record.user.id : record.id
  end

  def professional_name_of(record)
    if record.respond_to?(:full_name) && record.full_name.present?
      record.full_name
    elsif record.respond_to?(:name) && record.name.present?
      record.name
    elsif record.respond_to?(:user) && record.user
      record.user.respond_to?(:full_name) && record.user.full_name.present? ? record.user.full_name : record.user.name
    else
      ''
    end
  end

  def professional_specialties_of(record)
    if record.respond_to?(:specialities) && record.specialities.respond_to?(:pluck)
      record.specialities.pluck(:name)
    elsif record.respond_to?(:professional) && record.professional.respond_to?(:specialities)
      record.professional.specialities.pluck(:name)
    else
      []
    end
  end
end
