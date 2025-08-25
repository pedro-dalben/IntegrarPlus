# frozen_string_literal: true

module Admin
  class ProfessionalPermissionsController < Admin::BaseController
    before_action :ensure_can_manage_permissions

    def index
      @professionals = Professional.order(:full_name)
    end

    def update
      @professional = Professional.find(params[:id])

      # Converter string para array de inteiros
      permissions = params[:system_permissions]&.map(&:to_i) || []

      if @professional.update(system_permissions: permissions)
        redirect_to admin_professional_permissions_path, notice: 'Permissões atualizadas com sucesso!'
      else
        redirect_to admin_professional_permissions_path, alert: 'Erro ao atualizar permissões.'
      end
    end

    private

    def ensure_can_manage_permissions
      return if current_user.admin?
      return if current_user.permit?('documents.manage_permissions')
      return if current_user.professional&.can_manage_permissions?

      redirect_to admin_path, alert: 'Você não tem permissão para gerenciar permissões.'
    end
  end
end
