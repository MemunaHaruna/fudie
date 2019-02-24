class AuthenticationController < ApplicationController
  skip_before_action :authorize_api_request, only: :signin

  def signin
    user = User.find_by(email: auth_params[:email])
    if !user.activated?
      message = 'Account unactivated. Check your email for activation link'
      raise ExceptionHandler::AuthenticationError, message
    end
    token = Auth::AuthenticateUser.new(auth_params[:email], auth_params[:password]).call
    json_auth_response(token: token, message: 'Successfully logged in')
  end

  private

  def auth_params
    params.permit(:email, :password)
  end
end
