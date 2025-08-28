# frozen_string_literal: true

module Portal
  class ServiceRequestReferralsController < BaseController
    before_action :set_service_request
    before_action :set_service_request_referral, only: [:destroy]
    before_action :check_service_request_editable

    def create
      @service_request_referral = @service_request.service_request_referrals.build(service_request_referral_params)

      if @service_request_referral.save
        respond_to do |format|
          format.html { redirect_to edit_portal_service_request_path(@service_request), notice: 'Encaminhamento adicionado com sucesso.' }
          format.turbo_stream
        end
      else
        respond_to do |format|
          format.html { redirect_to edit_portal_service_request_path(@service_request), alert: 'Erro ao adicionar encaminhamento.' }
          format.turbo_stream { render :create_error }
        end
      end
    end

    def destroy
      @service_request_referral.destroy

      respond_to do |format|
        format.html { redirect_to edit_portal_service_request_path(@service_request), notice: 'Encaminhamento removido com sucesso.' }
        format.turbo_stream
      end
    end

    private

    def set_service_request
      @service_request = current_external_user.service_requests.find(params[:service_request_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to portal_service_requests_path, alert: 'Solicitação não encontrada.'
    end

    def set_service_request_referral
      @service_request_referral = @service_request.service_request_referrals.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to edit_portal_service_request_path(@service_request), alert: 'Encaminhamento não encontrado.'
    end

    def check_service_request_editable
      return unless @service_request.status == 'processado'

      redirect_to portal_service_request_path(@service_request),
                  alert: 'Solicitação já foi processada e não pode ser editada.'
    end

    def service_request_referral_params
      params.require(:service_request_referral).permit(:cid, :encaminhado_para, :medico, :descricao)
    end
  end
end
