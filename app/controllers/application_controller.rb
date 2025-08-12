# frozen_string_literal: true

class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  
  # CSRF protection
  protect_from_forgery with: :exception

  include Pundit::Authorization

  before_action :set_paper_trail_whodunnit
end
