class ApplicationController < ActionController::API
  rescue_from UserAuthenticator::AuthenticationError, with: :authentication_error

  def render(options={})
    options[:json] = serializer.new(options[:json]) if (options[:json].is_a?(ApplicationRecord) || options[:json].is_a?(ActiveRecord::Relation)) && respond_to?(:serializer, true)
    super(options)
  end

  private

  def authentication_error
    error = {
      'status' => '401',
      'source' => { 'pointer' => '/code' },
      'title' => 'Authentication code is invalid',
      'detail' => 'You must provide a valid code to get a token.'
    }
    render json: { "errors": [error] }, status: 401
  end
end
