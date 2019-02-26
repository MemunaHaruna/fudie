class PasswordResetsController < ApplicationController
  skip_before_action :authorize_api_request, only: [:create, :edit, :update]

  def create
    # clicking reset password in UI redirects user to form for entering email
    # clicking Reset saves form to this action
    check_if_email_is_present
    user = User.find_by(email: params[:email].downcase)
    check_if_user_exists(user)
    check_account_activation_status(user)
    user.create_password_reset_digest
    user.send_password_reset_email
    json_response(message: 'Email sent with password reset instructions')
  end

  def edit
    check_if_email_is_present
    user = User.find_by(email: params[:email].downcase)
    check_if_user_exists(user)
    check_account_activation_status(user)
    if user.authenticated?(:password_reset, params[:id])
      json_response(message: 'User confirmed successfully')
    else
      json_error_response(message: 'Error verifying user credentials')
    end
  end

  def update
    # clicking password reset link in email redirects user to a page where
    # they can enter password and password confirmation
    check_if_email_is_present
    user = User.find_by(email: params[:email])
    check_if_user_exists(user)
    if user.password_reset_expired?
      return json_error_response(message: 'Password reset link expired. Try generating a new one.')
    end

    check_account_activation_status(user)

    if !user.authenticated?(:password_reset, params[:id])
      return json_error_response(message: 'Error resetting password')
    end

    ensure_password_confirmation_is_present
    if user.reset_password!(params[:password])
      token = Auth::AuthenticateUser.new(params[:email], params[:password]).call
      json_auth_response(token: token, message: 'Successfully reset password')
    else
      json_error_response(message: user.errors.full_messages)
    end
  end

  private

  def ensure_password_confirmation_is_present
    if !params[:password_confirmation]
      raise ExceptionHandler::PasswordMismatch, "Password and Password Confirmation don't match"
    end
  end

  def check_account_activation_status(user)
    if !user.account_activated?
      return json_error_response(message: 'Kindly confirm your account')
    end
  end

  def check_if_email_is_present
    if params[:email].blank?
      return json_error_response(message: 'Email cannot be blank.')
    end
  end

  def check_if_user_exists(user)
    if !user
      raise ExceptionHandler::RecordNotFound, 'Error finding user'
    end
  end
end
