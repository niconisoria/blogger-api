class AccessTokensController < ApplicationController
  def create
    authenticator = UserAuthenticator.new(params[:code])
    authenticator.perform

    render json: authenticator.access_token, status: :created
  end

  def serializer
    AccessTokenSerializer
  end
end
