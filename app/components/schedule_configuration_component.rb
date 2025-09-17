class ScheduleConfigurationComponent < ViewComponent::Base
  def initialize(professional:, agenda: nil, read_only: false)
    @professional = professional
    @agenda = agenda
    @read_only = read_only
  end

  private

  attr_reader :professional, :agenda, :read_only

  def weekly_schedule
    return @weekly_schedule if defined?(@weekly_schedule)

    configuration_service = AvailabilityConfigurationService.new(professional, agenda)
    @weekly_schedule = configuration_service.get_weekly_schedule
  end

  def day_names
    Date::DAYNAMES
  end

  def time_slots
    (8..18).map do |hour|
      {
        value: "#{hour.to_s.rjust(2, '0')}:00",
        label: "#{hour.to_s.rjust(2, '0')}:00"
      }
    end
  end

  def templates
    [
      { id: 'standard_business_hours', name: 'Horário Comercial Padrão',
        description: 'Segunda a sexta, 08:00-12:00 e 13:00-17:00' },
      { id: 'extended_hours', name: 'Horário Estendido', description: 'Segunda a sexta, 07:00-19:00' },
      { id: 'weekend_coverage', name: 'Cobertura de Fim de Semana', description: 'Inclui sábado e domingo' }
    ]
  end
end
