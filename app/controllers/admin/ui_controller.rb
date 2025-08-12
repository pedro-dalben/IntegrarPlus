# frozen_string_literal: true

module Admin
  class UiController < BaseController
    skip_before_action :verify_authenticity_token, only: [:index]

    def index; end
  end
end
