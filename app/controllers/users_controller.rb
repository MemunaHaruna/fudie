class UsersController < ApplicationController
  skip_before_action :authorize_api_request, only: :create
  skip_before_action :require_active_member, only: :create
  before_action :set_user, only: [:show, :update]
  before_action :get_categories, only: :update

  def show
    if @user.active
      json_response(data: @user)
    else
      raise ExceptionHandler::UnauthorizedUser, 'You are not authorized to perform this action'
    end
  end

  def create
    ensure_password_confirmation_is_present
    user = User.create!(create_user_params)
    token = Auth::AuthenticateUser.new(user.email, user.password).call
    user.send_activation_email
    json_auth_response(token: token, message: 'Account created successfully', status: :created)
  rescue => error
    json_error_response(message: error.message)
  end

  def update
    if (@user.id != current_user.id || !@user.active)
      raise ExceptionHandler::UnauthorizedUser, 'You are not authorized to perform this action'
    end

    if @user.update(update_user_params)
      @user.avatar.attach(params[:avatar]) if params[:avatar]
      @user.categories << @categories if @categories

      json_response(data: @user, message: 'User updated successfully')
    else
      json_error_response(errors: @user.errors)
    end
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

  def update_user_params
    params.permit(:first_name, :last_name, :bio)
  end

  def get_categories
    # ids = JSON.parse(params[:category_ids]) if params[:category_ids] #temporarily remove this until needed
    @categories = Category.where(id: params[:category_ids])
  end

  def set_user
    @user ||= User.find(params[:id])
  end
end
