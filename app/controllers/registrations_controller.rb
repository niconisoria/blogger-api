class RegistrationsController < ApplicationController
  skip_before_action :authorize!, only: [:create]

  def create
    user = User.new(registation_params.merge(provider: 'standard'))
    user.save!
    render json: user, status: :created
  rescue ActiveRecord::RecordInvalid
    render json: user, status: :unprocessable_entity, error: true
  end

  private

  def registation_params
    params.require(:data).require(:attributes).permit(:login, :password) || ActionController::Parameters.new
  end
end
