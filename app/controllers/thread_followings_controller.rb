class ThreadFollowingsController < ApplicationController
  before_action :set_thread_following, only: :destroy

  def create
    thread = current_user.thread_followings.create!(thread_params)
    json_response(status: :created,
      message: 'Successfully subscribed to thread',
      data: thread
    )
  rescue => error
    json_error_response(message: error.message)
  end

  def destroy
    if @thread_following.user_id != current_user.id
      raise ExceptionHandler::UnauthorizedUser, 'You are not authorized to perform this action'
    end

    @thread_following.destroy
    json_basic_response(message: 'Successfully unsubscribed from thread')
  end

  def thread_params
    params.permit(:post_id)
  end

  def set_thread_following
    @thread_following = ThreadFollowing.find(params[:id])
  end
end
