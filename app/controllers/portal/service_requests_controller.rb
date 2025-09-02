# frozen_string_literal: true

module Portal
  class ServiceRequestsController < BaseController
    before_action :set_service_request, only: %i[show edit update destroy]

    def index
      @service_requests = current_external_user.service_requests
                                               .includes(:service_request_referrals)
                                               .recent

      apply_filters

      @pagy, @service_requests = pagy(@service_requests, items: 10)

      respond_to do |format|
        format.html
        format.json { render json: { results: @service_requests, count: @pagy.count } }
      end
    end

    def show
      @service_request_referrals = @service_request.service_request_referrals.includes(:service_request)
    end

    def new
      @service_request = current_external_user.service_requests.build
      @service_request.data_encaminhamento = Date.current
      @service_request.convenio = current_external_user.company_name
      @service_request.service_request_referrals.build
    end

    def edit
      if @service_request.status == 'processado'
        return redirect_to portal_service_request_path(@service_request),
                           alert: 'Solicitação já foi processada e não pode ser editada.'
      end

      @service_request.service_request_referrals.build if @service_request.service_request_referrals.empty?
    end

    def create
      @service_request = current_external_user.service_requests.build(service_request_params)
      @service_request.data_encaminhamento = Date.current if @service_request.data_encaminhamento.blank?
      @service_request.convenio = current_external_user.company_name if @service_request.convenio.blank?

      if @service_request.save
        redirect_to portal_service_request_path(@service_request),
                    notice: 'Solicitação criada com sucesso.'
      else
        @service_request.service_request_referrals.build if @service_request.service_request_referrals.empty?
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @service_request.status == 'processado'
        return redirect_to portal_service_request_path(@service_request),
                           alert: 'Solicitação já foi processada e não pode ser editada.'
      end

      if @service_request.update(service_request_params)
        redirect_to portal_service_request_path(@service_request),
                    notice: 'Solicitação atualizada com sucesso.'
      else
        @service_request.service_request_referrals.build if @service_request.service_request_referrals.empty?
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @service_request.status == 'processado'
        return redirect_to portal_service_requests_path,
                           alert: 'Solicitação já foi processada e não pode ser excluída.'
      end

      @service_request.destroy
      redirect_to portal_service_requests_path, notice: 'Solicitação excluída com sucesso.'
    end

    private

    def set_service_request
      @service_request = current_external_user.service_requests.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to portal_service_requests_path, alert: 'Solicitação não encontrada.'
    end

    def service_request_params
      params.expect(
        service_request: [:convenio, :carteira_codigo, :nome, :telefone_responsavel, :data_encaminhamento,
                          { service_request_referrals_attributes: %i[
                            id cid encaminhado_para medico medico_crm data_encaminhamento descricao _destroy
                          ] }]
      )
    end

    def apply_filters
      @service_requests = @service_requests.by_status(params[:status]) if params[:status].present?

      if params[:data_inicio].present? && params[:data_fim].present?
        @service_requests = @service_requests.by_date_range(
          Date.parse(params[:data_inicio]),
          Date.parse(params[:data_fim])
        )
      end
    rescue Date::Error
      # Ignora datas inválidas
    end
  end
end
