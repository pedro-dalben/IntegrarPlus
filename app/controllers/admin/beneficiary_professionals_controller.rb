# frozen_string_literal: true

module Admin
  class BeneficiaryProfessionalsController < BaseController
    before_action :set_beneficiary

    def create
      authorize @beneficiary, policy_class: Admin::BeneficiaryPolicy
      unless current_user.permit?('beneficiary.tabs.professionals.edit')
        return redirect_to admin_beneficiary_path(@beneficiary, tab: 'professionals'),
                           alert: 'Você não tem permissão para editar profissionais.'
      end

      professional_id = params[:professional_id]
      if professional_id.blank?
        return redirect_to admin_beneficiary_path(@beneficiary, tab: 'professionals'),
                           alert: 'Profissional inválido.'
      end

      relation = @beneficiary.beneficiary_professionals.find_or_initialize_by(professional_id: professional_id)
      if relation.save
        redirect_to admin_beneficiary_path(@beneficiary, tab: 'professionals'),
                    notice: 'Profissional relacionado com sucesso.',
                    status: :see_other
      else
        redirect_to admin_beneficiary_path(@beneficiary, tab: 'professionals'),
                    alert: 'Não foi possível relacionar o profissional.',
                    status: :see_other
      end
    end

    def destroy
      authorize @beneficiary, policy_class: Admin::BeneficiaryPolicy
      unless current_user.permit?('beneficiary.tabs.professionals.edit')
        return redirect_to admin_beneficiary_path(@beneficiary, tab: 'professionals'),
                           alert: 'Você não tem permissão para editar profissionais.'
      end

      relation = @beneficiary.beneficiary_professionals.find_by(id: params[:id])
      if relation&.destroy
        redirect_to admin_beneficiary_path(@beneficiary, tab: 'professionals'),
                    notice: 'Profissional removido com sucesso.',
                    status: :see_other
      else
        redirect_to admin_beneficiary_path(@beneficiary, tab: 'professionals'),
                    alert: 'Não foi possível remover o profissional.',
                    status: :see_other
      end
    end

    private

    def set_beneficiary
      @beneficiary = Beneficiary.find(params[:beneficiary_id])
    end
  end
end
