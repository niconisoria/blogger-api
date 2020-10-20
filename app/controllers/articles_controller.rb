class ArticlesController < ApplicationController
    def index
        render json: Article.all
    end

    def show
    end

    private

    def serializer
        ArticleSerializer
    end
end
