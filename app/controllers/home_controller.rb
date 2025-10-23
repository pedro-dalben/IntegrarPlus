# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @news = News.published.recent.limit(6)
  end
end
