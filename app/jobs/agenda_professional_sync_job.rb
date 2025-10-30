# frozen_string_literal: true

class AgendaProfessionalSyncJob < ApplicationJob
  queue_as :default

  def perform(agenda_id)
    agenda = Agenda.find_by(id: agenda_id)
    return unless agenda

    AgendaProfessionalSyncService.new(agenda).sync_from_working_hours
  end
end
