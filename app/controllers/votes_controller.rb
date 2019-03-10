class VotesController < ApplicationController
  before_action :set_post
  before_action :set_user
  before_action :set_vote, only: :update

  def create
    vote = @post.votes.create!(post_params)
    json_response(status: :created,
                    message: 'Successfully voted for post',
                    data: vote
                  )
  rescue => error
    json_error_response(message: error.message)
  end

  def update
    if @vote.update(post_update_params)
      json_response(message: 'Successfully voted for post', data: @vote)
    else
      json_error_response(message: error.message)
    end
  end

  private
    def set_post
      @post = Post.find(params[:post_id])
    end

    def set_user
      @user = User.find(params[:user_id])
    end

    def set_vote
      @vote = Vote.find(params[:id])
    end

    def post_params
      params.permit(:user_id, :vote_type)
    end

    def post_update_params
      params.permit(:vote_type)
    end
end
