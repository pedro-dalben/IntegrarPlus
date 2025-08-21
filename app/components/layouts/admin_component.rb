# frozen_string_literal: true

module Layouts
  class AdminComponent < ViewComponent::Base
    renders_one :actions

    def initialize(title: nil)
      @title = title
    end

    private

    attr_reader :title
  end
end
