class Admin::FlagsController < Admin::ApplicationController
  before_action :get_flag, except: :index

  def index
    flags = Flag.where(reviewed_by_admin: false).page(params[:page]).per(params[:per_page] || 10)
    json_response(status: :ok, data: flags)
  end

  def show
    if @flag
      json_response(status: :ok, data: @flag)
    else
      raise ActiveRecord::RecordNotFound, 'Unable to retrieve flag'
    end
  end

  def update
    if @flag.update(reviewed_by_admin: true)
      @flag.flaggable.update(update_flag_params)
      json_response(status: :ok, data: @flag)
    else
      raise ActiveRecord::RecordNotFound, 'Unable to update flag'
    end
  end

  private

  def update_flag_params
    params.permit(:deactivated_by_admin)
  end

  def get_flag
    @flag ||= Flag.find(params[:id])
  end
end
