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
    if flag_type == "post"
      @flagged = Post.find(params[:flagged_id].to_i)
    elsif flag_type == "user"
      @flagged = User.find(params[:flagged_id].to_i)
    else
      raise ActiveRecord::RecordInvalid, 'Unable to flag record type'
    end
  end

  def flag_type
    flag_type = params[:flag_type].downcase
    flag_type[0..4]
  end

end
