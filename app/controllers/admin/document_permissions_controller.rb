class Admin::DocumentPermissionsController < Admin::BaseController
  before_action :set_document
  before_action :ensure_can_manage_permissions

  def index
    @permissions = @document.document_permissions.includes(:user, :group)
    @users = User.where.not(id: @document.author&.user&.id).order(:name)
    @groups = Group.ordered
  end

  def create
    grantee_type = params[:grantee_type]
    grantee_id = params[:grantee_id]
    access_level = params[:access_level]

    begin
      grantee = find_grantee(grantee_type, grantee_id)

      if grantee
        @document.grant_permission(grantee, access_level)

        respond_to do |format|
          format.html do
            redirect_to admin_document_document_permissions_path(@document), notice: 'Permissão concedida com sucesso!'
          end
          format.json { render json: { success: true, message: 'Permissão concedida com sucesso!' } }
        end
      else
        respond_to do |format|
          format.html do
            redirect_to admin_document_document_permissions_path(@document), alert: 'Usuário ou grupo não encontrado.'
          end
          format.json { render json: { error: 'Usuário ou grupo não encontrado.' }, status: :not_found }
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      respond_to do |format|
        format.html { redirect_to admin_document_document_permissions_path(@document), alert: e.message }
        format.json { render json: { error: e.message }, status: :unprocessable_entity }
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
    case grantee_type
    when 'user'
      User.find_by(id: grantee_id)
    when 'group'
      Group.find_by(id: grantee_id)
    end
  end
end
