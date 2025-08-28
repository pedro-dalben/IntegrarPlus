# frozen_string_literal: true

module Portal
  class HeaderComponent < ViewComponent::Base
    def initialize(external_user:)
      @external_user = external_user
    end

    private

    attr_reader :external_user
  end
end
