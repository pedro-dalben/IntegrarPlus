# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    layout 'admin'
    
    before_action :authenticate_user!

    helper_method :admin_nav

    private

    def admin_nav
      AdminNav.items
    end
  end
end
