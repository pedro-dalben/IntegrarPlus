# frozen_string_literal: true

module Admin
  class DocumentPermissionsController < Admin::BaseController
    before_action :set_document
    before_action :ensure_can_manage_permissions

    def index
      @permissions = @document.document_permissions.includes(:user, :group)
      @users = User.joins(:professional).where.not(professionals: { id: nil }).order('professionals.full_name')
      @groups = Group.ordered
    end

    def create
      Rails.logger.info "Criando permissão: #{params.inspect}"
      grantee_type = params[:grantee_type]
      user_ids = params[:user_id]&.reject(&:blank?)
      group_ids = params[:group_id]&.reject(&:blank?)
      access_level = params[:access_level]

      begin
        success_count = 0
        error_count = 0

        if grantee_type == 'user' && user_ids.present?
          user_ids.each do |user_id|
            user = User.find_by(id: user_id)
            if user
              @document.grant_permission(user, access_level)
              success_count += 1
            else
              error_count += 1
            end
          end
        elsif grantee_type == 'group' && group_ids.present?
          group_ids.each do |group_id|
            group = Group.find_by(id: group_id)
            if group
              @document.grant_permission(group, access_level)
              success_count += 1
            else
              error_count += 1
            end
          end
        else
          error_count += 1
        end

        if success_count.positive?
          message = "#{success_count} permissão(ões) concedida(s) com sucesso!"
          message += " #{error_count} erro(s) encontrado(s)." if error_count.positive?

          respond_to do |format|
            format.html do
              redirect_to admin_document_document_permissions_path(@document), notice: message
            end
            format.json { render json: { success: true, message: message } }
          end
        else
          respond_to do |format|
            format.html do
              redirect_to admin_document_document_permissions_path(@document),
                          alert: 'Nenhuma permissão foi concedida. Verifique os dados selecionados.'
            end
            format.json { render json: { error: 'Nenhuma permissão foi concedida' }, status: :unprocessable_entity }
          end
        end
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error "Erro de validação: #{e.message}"
        respond_to do |format|
          format.html { redirect_to admin_document_document_permissions_path(@document), alert: e.message }
          format.json { render json: { error: e.message }, status: :unprocessable_entity }
        end
      rescue ArgumentError => e
        Rails.logger.error "Erro de argumento: #{e.message}"
        respond_to do |format|
          format.html { redirect_to admin_document_document_permissions_path(@document), alert: e.message }
          format.json { render json: { error: e.message }, status: :unprocessable_entity }
        end
      rescue StandardError => e
        Rails.logger.error "Erro inesperado: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        respond_to do |format|
          format.html do
            redirect_to admin_document_document_permissions_path(@document),
                        alert: 'Erro interno do servidor. Tente novamente.'
          end
          format.json { render json: { error: 'Erro interno do servidor' }, status: :internal_server_error }
        end
      end
    end

    def destroy
      permission = @document.document_permissions.find(params[:id])
      grantee = permission.user || permission.group

      if @document.revoke_permission(grantee)
        respond_to do |format|
          format.html do
            redirect_to admin_document_document_permissions_path(@document), notice: 'Permissão revogada com sucesso!'
          end
          format.json { render json: { success: true, message: 'Permissão revogada com sucesso!' } }
        end
      else
        respond_to do |format|
          format.html do
            redirect_to admin_document_document_permissions_path(@document), alert: 'Erro ao revogar permissão.'
          end
          format.json { render json: { error: 'Erro ao revogar permissão.' }, status: :unprocessable_entity }
        end
      end
    end

    private

    def set_document
      @document = Document.find(params[:document_id])
    end

    def ensure_can_manage_permissions
      return if @document.user_can_edit?(current_user)

      respond_to do |format|
        format.html do
          redirect_to @document, alert: 'Você não tem permissão para gerenciar permissões deste documento.'
        end
        format.json { render json: { error: 'Acesso negado' }, status: :forbidden }
      end
    end

    def find_grantee(grantee_type, grantee_id)
      Rails.logger.info "Buscando grantee: tipo=#{grantee_type}, id=#{grantee_id}"

      return nil if grantee_type.blank? || grantee_id.blank?

      case grantee_type
      when 'user'
        user = User.find_by(id: grantee_id)
        Rails.logger.info "Usuário encontrado: #{user&.name}"
        user
      when 'group'
        group = Group.find_by(id: grantee_id)
        Rails.logger.info "Grupo encontrado: #{group&.name}"
        group
      else
        Rails.logger.error "Tipo de grantee inválido: #{grantee_type}"
        nil
      end
    end
  end
end
