# frozen_string_literal: true

module Layouts
  class AdminComponent < ViewComponent::Base
    renders_one :actions

    def initialize(title: nil, subtitle: nil)
      @title = title
      @subtitle = subtitle
    end

    private

    attr_reader :title, :subtitle
  end
end
