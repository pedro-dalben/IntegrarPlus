# frozen_string_literal: true

module Admin
  class PortalIntakesController < BaseController
    before_action :set_portal_intake, only: %i[show update schedule_anamnesis]

    def index
      @portal_intakes = policy_scope(PortalIntake, policy_scope_class: Admin::PortalIntakePolicy::Scope)
                        .includes(:operator, :journey_events)
                        .recent

      @portal_intakes = apply_filters(@portal_intakes)
      @pagy, @portal_intakes = pagy(@portal_intakes, items: 20)

      @operators = ExternalUser.active.order(:company_name)
      @statuses = PortalIntake.statuses.keys

      respond_to do |format|
        format.html
        format.json { render json: { results: @portal_intakes, count: @pagy.count } }
      end
    end

    def show
      authorize @portal_intake, policy_class: Admin::PortalIntakePolicy
      @journey_events = @portal_intake.journey_events.recent
    end

    def update
      authorize @portal_intake, policy_class: Admin::PortalIntakePolicy

      if @portal_intake.update(portal_intake_params)
        redirect_to admin_portal_intake_path(@portal_intake),
                    notice: 'Entrada atualizada com sucesso.'
      else
        render :show, status: :unprocessable_entity
      end
    end

    def schedule_anamnesis
      authorize @portal_intake, policy_class: Admin::PortalIntakePolicy

      if params[:anamnesis_scheduled_on].present?
        begin
          date = Date.parse(params[:anamnesis_scheduled_on])
          @portal_intake.schedule_anamnesis!(date, current_user)

          redirect_to admin_portal_intake_path(@portal_intake),
                      notice: "Anamnese agendada para #{date.strftime('%d/%m/%Y')} com sucesso."
        rescue Date::Error
          redirect_to admin_portal_intake_path(@portal_intake),
                      alert: 'Data inválida fornecida.'
        rescue StandardError => e
          redirect_to admin_portal_intake_path(@portal_intake),
                      alert: "Erro ao agendar anamnese: #{e.message}"
        end
      else
        redirect_to admin_portal_intake_path(@portal_intake),
                    alert: 'Data é obrigatória para agendar anamnese.'
      end
    end

    private

    def set_portal_intake
      @portal_intake = PortalIntake.find(params[:id])
    end

    def portal_intake_params
      params.expect(portal_intake: %i[beneficiary_name plan_name card_code])
    end

    def apply_filters(scope)
      scope = scope.by_operator(params[:operator_id]) if params[:operator_id].present?
      scope = scope.by_status(params[:status]) if params[:status].present?

      if params[:start_date].present? && params[:end_date].present?
        begin
          start_date = Date.parse(params[:start_date])
          end_date = Date.parse(params[:end_date])
          scope = scope.requested_between(start_date, end_date)
        rescue Date::Error
          # Ignora filtro de data se inválido
        end
      end

      scope
    end
  end
end
