# frozen_string_literal: true

module Ui
  class ShowSectionComponent < ViewComponent::Base
    renders_many :fields

    def initialize(title:, subtitle: nil)
      @title = title
      @subtitle = subtitle
    end

    private

    attr_reader :title, :subtitle
  end
end
