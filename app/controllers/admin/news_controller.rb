class Admin::NewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_news, only: %i[show edit update destroy]

  def index
    @news = News.recent.page(params[:page])
  end

  def show
  end

  def new
    @news = News.new
  end

  def edit
  end

  def create
    @news = News.new(news_params)
    @news.author = current_user.email

    if @news.save
      redirect_to admin_news_index_path, notice: 'Notícia criada com sucesso.'
    else
      render :new
    end
  end

  def update
    if @news.update(news_params)
      redirect_to admin_news_index_path, notice: 'Notícia atualizada com sucesso.'
    else
      render :edit
    end
  end

  def destroy
    @news.destroy
    redirect_to admin_news_index_path, notice: 'Notícia removida com sucesso.'
  end

  private

  def set_news
    @news = News.find(params[:id])
  end

  def news_params
    params.require(:news).permit(:title, :content, :published, :published_at)
  end
end
