class ApplicationController < ActionController::API
  class AuthorizationError < StandardError; end
  rescue_from UserAuthenticator::Oauth::AuthenticationError, with: :authentication_oauth_error
  rescue_from UserAuthenticator::Standard::AuthenticationError, with: :authentication_standard_error
  rescue_from AuthorizationError, with: :authorization_error

  before_action :authorize!

  private

  def render(options={})
    if options[:error]
      options[:json] = ErrorSerializer.new(options[:json]).serializable_hash.to_json
    elsif (options[:json].is_a?(ApplicationRecord) || options[:json].is_a?(ActiveRecord::Relation)) && respond_to?(:serializer, true)
      options[:json] = serializer.new(options[:json])
    end
    super(options)
  end

  def authorize!
    raise AuthorizationError unless current_user
  end

  def access_token
    provided_token = request.authorization&.gsub(/\ABearer\s/, '')
    @access_token = AccessToken.find_by(token: provided_token)
  end

  def current_user
    @current_user = access_token&.user
  end

  def authentication_oauth_error
    error = {
      'status' => '401',
      'source' => { 'pointer' => '/code' },
      'title' => 'Authentication code is invalid',
      'detail' => 'You must provide a valid code to get a token.'
    }
    render json: { "errors": [error] }, status: 401
  end

  def authentication_standard_error
    error = {
      'status' => '401',
      'source' => { 'pointer' => '/data/attributes/password' },
      'title' => 'Invalid login or password',
      'detail' => 'You must provide valid credentials to get a token.'
    }
    render json: { "errors": [error] }, status: 401
  end

  def authorization_error
    error = {
      'status' => '403',
      'source' => { 'pointer' => '/headers/authorization' },
      'title' => 'Not authorized',
      'detail' => 'You are not authorized to access this resource.'
    }
    render json: { "errors": [error] }, status: 403
  end
end
