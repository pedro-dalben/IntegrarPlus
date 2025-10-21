# frozen_string_literal: true

module Home
  class NewsSectionComponent < ViewComponent::Base
    def initialize(news:)
      @news = news
    end

    private

    attr_reader :news
  end
end
