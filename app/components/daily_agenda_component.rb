# frozen_string_literal: true

class DailyAgendaComponent < ViewComponent::Base
  include EventsHelper

  def initialize(events: [], date: Date.current)
    @events = events
    @date = date
  end

  private

  attr_reader :events, :date

  def time_slots
    (8..17).map do |hour|
      (0..3).map do |quarter|
        time = "#{hour.to_s.rjust(2, '0')}:#{(quarter * 15).to_s.rjust(2, '0')}"
        {
          time: time,
          datetime: Time.zone.parse("#{date} #{time}"),
          event: find_event_at_time(time)
        }
      end
    end.flatten
  end

  def find_event_at_time(time)
    events.find { |event| event.start_time.in_time_zone.strftime('%H:%M') == time }
  end

  def hour_groups
    time_slots.group_by { |slot| slot[:time].split(':').first }
  end

  def event_style(event)
    case event.event_type
    when 'consulta'
      'bg-green-100 dark:bg-green-900/20 text-green-800 dark:text-green-200 border-green-200 dark:border-green-700'
    when 'atendimento'
      'bg-blue-100 dark:bg-blue-900/20 text-blue-800 dark:text-blue-200 border-blue-200 dark:border-blue-700'
    when 'reuniao'
      'bg-purple-100 dark:bg-purple-900/20 text-purple-800 dark:text-purple-200 border-purple-200 dark:border-purple-700'
    when 'anamnese'
      'bg-orange-100 dark:bg-orange-900/20 text-orange-800 dark:text-orange-200 border-orange-200 dark:border-orange-700'
    when 'personal'
      'bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 border-gray-200 dark:border-gray-600'
    else
      'bg-indigo-100 dark:bg-indigo-900/20 text-indigo-800 dark:text-indigo-200 border-indigo-200 dark:border-indigo-700'
    end
  end

  def event_dot_color(event)
    case event.event_type
    when 'consulta'
      '#10b981'
    when 'atendimento'
      '#3b82f6'
    when 'reuniao'
      '#8b5cf6'
    when 'anamnese'
      '#f59e0b'
    when 'personal'
      '#6b7280'
    else
      '#6366f1'
    end
  end
end
