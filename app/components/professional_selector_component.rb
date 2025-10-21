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
end
