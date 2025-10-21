# frozen_string_literal: true

module EventsHelper
  def event_color(event_type)
    case event_type
    when 'personal'
      '#3b82f6'
    when 'consulta'
      '#10b981'
    when 'atendimento'
      '#f59e0b'
    when 'reuniao'
      '#8b5cf6'
    when 'outro'
      '#6b7280'
    else
      '#3b82f6'
    end
  end

  def event_badge_class(event_type)
    case event_type
    when 'personal'
      'bg-blue-100 text-blue-800 dark:bg-blue-900/20 dark:text-blue-300'
    when 'consulta'
      'bg-green-100 text-green-800 dark:bg-green-900/20 dark:text-green-300'
    when 'atendimento'
      'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/20 dark:text-yellow-300'
    when 'reuniao'
      'bg-purple-100 text-purple-800 dark:bg-purple-900/20 dark:text-purple-300'
    when 'outro'
      'bg-gray-100 text-gray-800 dark:bg-gray-900/20 dark:text-gray-300'
    else
      'bg-gray-100 text-gray-800 dark:bg-gray-900/20 dark:text-gray-300'
    end
  end

  def visibility_badge_class(visibility_level)
    case visibility_level
    when 'personal_private' then 'bg-red-100 text-red-800 dark:bg-red-900/20 dark:text-red-300'
    when 'restricted' then 'bg-orange-100 text-orange-800 dark:bg-orange-900/20 dark:text-orange-300'
    when 'publicly_visible' then 'bg-green-100 text-green-800 dark:bg-green-900/20 dark:text-green-300'
    else 'bg-gray-100 text-gray-800 dark:bg-gray-900/20 dark:text-gray-300'
    end
  end

  def format_event_time(event)
    start_time = event.start_time.strftime('%H:%M')
    end_time = event.end_time.strftime('%H:%M')
    "#{start_time} - #{end_time}"
  end

  def format_event_date(event)
    event.start_time.strftime('%d/%m/%Y')
  end

  def format_event_datetime(event)
    event.start_time.strftime('%d/%m/%Y às %H:%M')
  end

  def event_duration_minutes(event)
    ((event.end_time - event.start_time) / 1.minute).to_i
  end

  def event_duration_text(event)
    minutes = event_duration_minutes(event)
    if minutes < 60
      "#{minutes} min"
    else
      hours = minutes / 60
      remaining_minutes = minutes % 60
      if remaining_minutes.zero?
        "#{hours}h"
      else
        "#{hours}h#{remaining_minutes}min"
      end
    end
  end

  def event_status_badge_class(status)
    case status
    when 'active'
      'bg-green-100 text-green-800 dark:bg-green-900/20 dark:text-green-300'
    when 'cancelled'
      'bg-red-100 text-red-800 dark:bg-red-900/20 dark:text-red-300'
    when 'completed'
      'bg-blue-100 text-blue-800 dark:bg-blue-900/20 dark:text-blue-300'
    else
      'bg-gray-100 text-gray-800 dark:bg-gray-900/20 dark:text-gray-300'
    end
  end

  def event_type_icon(event_type)
    case event_type
    when 'personal'
      'M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z'
    when 'consulta'
      'M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z'
    when 'atendimento'
      'M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z'
    when 'reuniao'
      'M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z'
    when 'outro'
      'M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z'
    else
      'M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z'
    end
  end
end
