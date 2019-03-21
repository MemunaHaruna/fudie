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

  def pagination_dict(collection)
    {
      current_page: collection.current_page,
      next_page: collection.next_page,
      prev_page: collection.prev_page,
      total_pages: collection.total_pages,
      total_records: collection.total_count,
      records_per_page: collection.size
    }
  end
end
