class HomeController < ApplicationController
  skip_before_action :authorize_api_request, only: :index
  skip_before_action :require_active_member, only: :index

  def index
    render json: {"message": 'Welcome to Fudie API'}
  end
end
