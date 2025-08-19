# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    skip_before_action :authenticate_user!, only: [:index]

    def index; end
  end
end
