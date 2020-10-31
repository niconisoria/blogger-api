class CommentsController < ApplicationController
  skip_before_action :authorize!, only: [:index]
  before_action :load_article, only: [:index, :create]

  def index
    comments = paginate @article.comments.page(params[:page]).per(params[:per_page])
    render json: comments
  end

  def create
    @comment = @article.comments.build(comment_params.merge(user: current_user))
    @comment.save!
    render json: @comment, status: :created
  rescue ActiveRecord::RecordNotFound
    authorization_error
  rescue ActiveRecord::RecordInvalid
    render json: @comment, status: :unprocessable_entity, error: true
  end

  private

  def serializer
    CommentSerializer
  end

  def load_article
    @article = Article.find(params[:article_id])
  end

  def comment_params
    params.require(:data).require(:attributes).permit(:content)
  end
end
