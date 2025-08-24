class Admin::VersionCommentsController < Admin::BaseController
  before_action :set_document_version
  before_action :ensure_can_comment, only: [:create]
  before_action :set_comment, only: %i[update destroy]
  before_action :ensure_can_edit_comment, only: %i[update destroy]

  def create
    @comment = @document_version.version_comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      respond_to do |format|
        format.html do
          redirect_to document_path(@document_version.document), notice: 'Comentário adicionado com sucesso!'
        end
        format.json { render json: { success: true, comment: render_comment(@comment) } }
        format.turbo_stream do
          render turbo_stream: turbo_stream.append("comments-#{@document_version.id}", partial: 'version_comments/comment',
                                                                                       locals: { comment: @comment })
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to document_path(@document_version.document), alert: 'Erro ao adicionar comentário.' }
        format.json { render json: { error: @comment.errors.full_messages.join(', ') }, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace('comment-form', partial: 'version_comments/form',
                                                                    locals: { comment: @comment, document_version: @document_version })
        end
      end
    end
  end

  def update
    if @comment.update(comment_params)
      respond_to do |format|
        format.html do
          redirect_to document_path(@document_version.document), notice: 'Comentário atualizado com sucesso!'
        end
        format.json { render json: { success: true, comment: render_comment(@comment) } }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("comment-#{@comment.id}", partial: 'version_comments/comment',
                                                                              locals: { comment: @comment })
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to document_path(@document_version.document), alert: 'Erro ao atualizar comentário.' }
        format.json { render json: { error: @comment.errors.full_messages.join(', ') }, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("comment-#{@comment.id}", partial: 'version_comments/comment_edit',
                                                                              locals: { comment: @comment })
        end
      end
    end
  end

  def destroy
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to document_path(@document_version.document), notice: 'Comentário removido com sucesso!' }
      format.json { render json: { success: true } }
      format.turbo_stream { render turbo_stream: turbo_stream.remove("comment-#{@comment.id}") }
    end
  end

  private

  def set_document_version
    @document_version = DocumentVersion.find(params[:document_version_id])
  end

  def set_comment
    @comment = @document_version.version_comments.find(params[:id])
  end

  def ensure_can_comment
    return if @document_version.document.user_can_comment?(current_user)

    respond_to do |format|
      format.html do
        redirect_to @document_version.document, alert: 'Você não tem permissão para comentar neste documento.'
      end
      format.json { render json: { error: 'Acesso negado' }, status: :forbidden }
    end
  end

  def ensure_can_edit_comment
    return if @comment.can_be_edited_by?(current_user)

    respond_to do |format|
      format.html do
        redirect_to @document_version.document, alert: 'Você não tem permissão para editar este comentário.'
      end
      format.json { render json: { error: 'Acesso negado' }, status: :forbidden }
    end
  end

  def comment_params
    params.require(:version_comment).permit(:comment_text)
  end

  def render_comment(comment)
    {
      id: comment.id,
      comment_text: comment.comment_text,
      user_name: comment.user.full_name,
      created_at: comment.created_at,
      can_edit: comment.can_be_edited_by?(current_user),
      can_delete: comment.can_be_deleted_by?(current_user)
    }
  end
end
