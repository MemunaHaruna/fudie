class ApplicationController < ActionController::API

  include ::ActionController::Serialization
  include ExceptionHandler
  include Response

  before_action :authorize_api_request
  attr_reader :current_user

  def authorize_api_request
    @current_user ||= Auth::AuthorizeApiRequest.new(request.headers).call[:user]
  end

  def require_admin
    unless current_user.admin?
      raise ExceptionHandler::UnauthorizedUser, 'You are not authorized to perform this action'
    end
  end
end
