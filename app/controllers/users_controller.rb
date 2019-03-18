class UsersController < ApplicationController
  skip_before_action :authorize_api_request, only: :create

  def create
    ensure_password_confirmation_is_present
    user = User.create!(create_user_params)
    token = Auth::AuthenticateUser.new(user.email, user.password).call
    user.send_activation_email
    json_auth_response(token: token, message: 'Account created successfully', status: :created)
  rescue => error
    json_error_response(message: error.message)
  end

  private

  def create_user_params
    params.permit(:first_name, :last_name, :email, :username, :password, :password_confirmation)
  end

  def ensure_password_confirmation_is_present
    if !create_user_params[:password_confirmation]
      raise ExceptionHandler::PasswordMismatch, "Password and Password Confirmation don't match"
    end
  end
end
