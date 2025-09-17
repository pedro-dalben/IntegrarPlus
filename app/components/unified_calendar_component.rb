class UnifiedCalendarComponent < ViewComponent::Base
  def initialize(events: [], professional: nil, view_type: 'month', agenda: nil)
    @events = events
    @professional = professional
    @view_type = view_type
    @agenda = agenda
  end

  private

  attr_reader :events, :professional, :view_type, :agenda

  def current_date
    @current_date ||= Date.current
  end

  def start_of_period
    case view_type
    when 'month'
      current_date.beginning_of_month
    when 'week'
      current_date.beginning_of_week
    when 'day'
      current_date
    else
      current_date.beginning_of_month
    end
  end

  def end_of_period
    case view_type
    when 'month'
      current_date.end_of_month
    when 'week'
      current_date.end_of_week
    when 'day'
      current_date
    else
      current_date.end_of_month
    end
  end

  def filtered_events
    return events unless professional.present?

    events.select { |event| event.professional_id == professional.id }
  end

  def events_by_date
    @events_by_date ||= filtered_events.group_by { |event| event.start_time.to_date }
  end

  def events_for_date(date)
    events_by_date[date] || []
  end

  def calendar_days
    case view_type
    when 'month'
      month_days
    when 'week'
      week_days
    when 'day'
      [current_date]
    else
      month_days
    end
  end

  def month_days
    start_date = current_date.beginning_of_month.beginning_of_week
    end_date = current_date.end_of_month.end_of_week

    (start_date..end_date).to_a
  end

  def week_days
    current_date.all_week.to_a
  end

  def day_names
    Date::DAYNAMES
  end

  def event_types
    {
      'personal' => { color: 'bg-gray-500', label: 'Pessoal' },
      'consulta' => { color: 'bg-blue-500', label: 'Consulta' },
      'atendimento' => { color: 'bg-green-500', label: 'Atendimento' },
      'reuniao' => { color: 'bg-purple-500', label: 'Reunião' },
      'anamnese' => { color: 'bg-orange-500', label: 'Anamnese' },
      'outro' => { color: 'bg-gray-400', label: 'Outro' }
    }
  end

  def event_status_colors
    {
      'active' => 'border-green-500',
      'cancelled' => 'border-red-500',
      'completed' => 'border-blue-500'
    }
  end
end
