# frozen_string_literal: true

class AgendaProfessionalSyncService
  def initialize(agenda)
    @agenda = agenda
  end

  def sync_from_working_hours
    working = @agenda.working_hours
    return { success: true, synced: 0 } if working.blank? || working['weekdays'].blank?

    schedule_data = working['weekdays'].map do |d|
      {
        day_of_week: d['wday'],
        enabled: true,
        periods: (d['periods'] || []).map do |p|
          { start_time: p['start'] || p['start_time'], end_time: p['end'] || p['end_time'] }
        end
      }
    end

    synced = 0
    @agenda.professionals.find_each do |professional|
      svc = AvailabilityConfigurationService.new(professional, @agenda)
      result = svc.set_custom_schedule(schedule_data)
      synced += 1 if result[:success]
    end

    { success: true, synced: synced }
  end
end
