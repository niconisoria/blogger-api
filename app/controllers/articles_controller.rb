class ArticlesController < ApplicationController
  skip_before_action :authorize!, only: [:index, :show]

  def index
    articles = paginate Article.recent.page(params[:page]).per(params[:per_page])
    render json: articles
  end

  def show
    render json: Article.find(params[:id])
  end

  def create
    article = Article.new(article_params)
    article.save!
    render json: article, status: :created
  rescue StandardError
    render json: article, status: :unprocessable_entity, error: true
  end

  private

  def article_params
    params.require(:data).require(:attributes).permit(:title, :content, :slug) || ActionController::Parameters.new
  end

  def serializer
    ArticleSerializer
  end
end
