# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    prepend_before_action :redirect_authenticated_user, only: [:new]
    after_action :set_user_last_seen, only: [:create]
    after_action :clear_user_last_seen, only: [:destroy]

    private

    def redirect_authenticated_user
      return unless warden.authenticated?(resource_name)

      respond_to do |format|
        format.html do
          redirect_to(after_sign_in_path_for(current_user || warden.user(resource_name)))
        end
        format.any { head :ok }
      end
    end

    def set_user_last_seen
      return unless user_signed_in?

      session[:user_last_seen_at] = Time.current.iso8601
    end

    def clear_user_last_seen
      session[:user_last_seen_at] = nil
    end
  end
end
