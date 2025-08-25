# frozen_string_literal: true

class AvatarsController < ApplicationController
  before_action :authenticate_user!

  def update
    if current_user.update(avatar_params)
      respond_to do |format|
        format.html { redirect_back(fallback_location: root_path, notice: 'Avatar atualizado com sucesso!') }
        format.json { render json: { success: true, message: 'Avatar atualizado com sucesso!' } }
      end
    else
      respond_to do |format|
        format.html { redirect_back(fallback_location: root_path, alert: 'Erro ao atualizar avatar.') }
        format.json { render json: { success: false, message: 'Erro ao atualizar avatar.' } }
      end
    end
  end

  def destroy
    current_user.avatar.purge
    redirect_back(fallback_location: root_path, notice: 'Avatar removido com sucesso!')
  end

  private

  def avatar_params
    params.expect(user: [:avatar])
  end
end
