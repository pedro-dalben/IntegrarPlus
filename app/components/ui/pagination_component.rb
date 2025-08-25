# frozen_string_literal: true

module Ui
  class PaginationComponent < ViewComponent::Base
    def initialize(pagy:)
      @pagy = pagy
    end

    private

    attr_reader :pagy
  end
end
