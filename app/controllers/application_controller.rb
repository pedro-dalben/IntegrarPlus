class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  include Pundit::Authorization

  before_action :set_paper_trail_whodunnit
end
