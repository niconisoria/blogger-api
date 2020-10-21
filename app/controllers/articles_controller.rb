class ArticlesController < ApplicationController
    def index
        render json: Article.recent
    end

    def show
    end

    private

    def serializer
        ArticleSerializer
    end
end
