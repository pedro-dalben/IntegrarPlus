# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    skip_before_action :authenticate_user!, only: [:index]

    def index
      @recent_professionals = Professional.order(created_at: :desc).limit(5)
    end
  end
end
