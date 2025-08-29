# frozen_string_literal: true

module PortalIntakeComponents
  class FiltersComponent < ViewComponent::Base
    def initialize(operators: [], statuses: [], current_params: {})
      @operators = operators
      @statuses = statuses
      @current_params = current_params
    end

    private

    attr_reader :operators, :statuses, :current_params

    def status_options
      statuses.map do |status|
        label = case status
                when 'aguardando_agendamento_anamnese'
                  'Aguardando Agendamento'
                when 'aguardando_anamnese'
                  'Aguardando Anamnese'
                when 'anamnese_concluida'
                  'Anamnese Concluída'
                else
                  status.humanize
                end
        [label, status]
      end
    end

    def operator_options
      operators.map { |op| [op.company_name, op.id] }
    end

    def selected_operator
      current_params[:operator_id]
    end

    def selected_status
      current_params[:status]
    end

    def start_date
      current_params[:start_date]
    end

    def end_date
      current_params[:end_date]
    end
  end
end
