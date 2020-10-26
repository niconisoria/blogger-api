class ArticlesController < ApplicationController
  skip_before_action :authorize!, only: [:index, :show]

  def index
    articles = paginate Article.recent.page(params[:page]).per(params[:per_page])
    render json: articles
  end

  def show
    render json: Article.find(params[:id])
  end

  private

  def serializer
    ArticleSerializer
  end
end
