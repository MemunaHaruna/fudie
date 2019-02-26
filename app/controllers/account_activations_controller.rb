class AccountActivationsController < ApplicationController
  skip_before_action :authorize_api_request, only: :edit

  def edit
    user = User.find_by(email: params[:email])
    if user && !user.account_activated? && user.authenticated?(:account_activation, params[:id])
      user.activate
      json_auth_response(message: 'Successfully confirmed account.')
    else
      json_error_response(message: 'Error confirming account.')
    end
  rescue => error
    json_error_response(message: error.message)
  end
end
