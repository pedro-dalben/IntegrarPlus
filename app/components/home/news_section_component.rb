class Home::NewsSectionComponent < ViewComponent::Base
  def initialize(news:)
    @news = news
  end

  private

  attr_reader :news
end


