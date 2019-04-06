class FlagsController < ApplicationController
  before_action :flagged_entity

  def create
    flag = @flagged.flags.create!(create_flag_params.merge(flagger_id: current_user.id))
    json_response(status: :ok, data: flag)
  rescue => error
    json_error_response(message: error.message)
  end

  private

  def create_flag_params
    params.permit(:reason)
  end

  def flagged_entity
    if flaggable_type == "post"
      @flagged = Post.find(params[:flaggable_id].to_i)
      check_validity(@flagged)
    elsif flaggable_type == "user"
      @flagged = User.find(params[:flaggable_id].to_i)
      check_validity(@flagged)
    else
      raise ExceptionHandler::InvalidParams, "Unable to flag record type"
    end
  end

  def flaggable_type
    if !params[:flaggable_type]
      raise ExceptionHandler::InvalidParams, "Flag type must be specified"
    end
    flaggable_type = params[:flaggable_type].downcase
    flaggable_type[0..4]
  end

  def check_validity(flagged)
    if flagged.owner == current_user
      raise ExceptionHandler::UnauthorizedUser, "You are not permitted to perform this action"
    end
  end
end
