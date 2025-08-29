# frozen_string_literal: true

module PortalIntakeComponents
  class StatusBadgeComponent < ViewComponent::Base
    def initialize(portal_intake:)
      @portal_intake = portal_intake
    end

    def call
      content_tag :span, status_label, class: status_classes
    end

    private

    def status_label
      @portal_intake.status_label
    end

    def status_classes
      base = 'inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium'

      case @portal_intake.status
      when 'aguardando_agendamento_anamnese'
        "#{base} text-yellow-700 bg-yellow-50"
      when 'aguardando_anamnese'
        "#{base} text-blue-700 bg-blue-50"
      when 'anamnese_concluida'
        "#{base} text-green-700 bg-green-50"
      else
        "#{base} text-gray-700 bg-gray-100"
      end
    end
  end
end
