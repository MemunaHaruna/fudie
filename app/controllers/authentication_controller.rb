class AuthenticationController < ApplicationController
  skip_before_action :authorize_api_request, only: :signin

  def signin
    token = Auth::AuthenticateUser.new(auth_params[:email], auth_params[:password]).call
    json_auth_response(token: token, message: 'Successfully logged in')
  end

  private

  def auth_params
    params.permit(:email, :password)
  end
end
