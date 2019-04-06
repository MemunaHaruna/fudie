class AuthenticationController < ApplicationController
  skip_before_action :authorize_api_request, only: :signin
  skip_before_action :require_active_member, only: :signin

  def signin
    user = User.find_by(email: auth_params[:email])
    raise ActiveRecord::RecordNotFound, 'User not found' unless user
    user.check_validity

    token = Auth::AuthenticateUser.new(auth_params[:email], auth_params[:password]).call
    json_auth_response(token: token, message: 'Successfully logged in')
  end

  private

  def auth_params
    params.permit(:email, :password)
  end
end
