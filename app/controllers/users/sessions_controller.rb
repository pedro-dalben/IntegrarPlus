class Users::SessionsController < Devise::SessionsController
  after_action :set_user_last_seen, only: [:create]
  after_action :clear_user_last_seen, only: [:destroy]

  private

  def set_user_last_seen
    return unless user_signed_in?

    session[:user_last_seen_at] = Time.current.iso8601
  end

  def clear_user_last_seen
    session[:user_last_seen_at] = nil
  end
end

