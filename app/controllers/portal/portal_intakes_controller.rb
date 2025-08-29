# frozen_string_literal: true

module Portal
  class PortalIntakesController < BaseController
    before_action :set_portal_intake, only: [:show]

    def index
      @portal_intakes = policy_scope(PortalIntake, policy_scope_class: PortalIntakePolicy::Scope)
                          .includes(:journey_events)
                          .recent

      @portal_intakes = apply_filters(@portal_intakes)
      @pagy, @portal_intakes = pagy(@portal_intakes, items: 20)

      @statuses = PortalIntake.statuses.keys
    end

    def show
      authorize @portal_intake
    end

    def new
      @portal_intake = PortalIntake.new
      authorize @portal_intake
    end

    def create
      @portal_intake = PortalIntake.new(portal_intake_params)
      @portal_intake.operator = current_external_user
      @portal_intake.requested_at = Time.current
      authorize @portal_intake

      if @portal_intake.save
        redirect_to portal_portal_intake_path(@portal_intake),
                    notice: 'Solicitação enviada com sucesso! Aguarde o agendamento da anamnese.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def set_portal_intake
      @portal_intake = PortalIntake.find(params[:id])
    end

    def portal_intake_params
      params.require(:portal_intake).permit(:beneficiary_name, :plan_name, :card_code)
    end

    def apply_filters(scope)
      scope = scope.by_status(params[:status]) if params[:status].present?
      scope = scope.requested_between(Date.parse(params[:start_date]), Date.parse(params[:end_date])) if params[:start_date].present? && params[:end_date].present?
      scope
    rescue Date::Error
      scope
    end
  end
end
