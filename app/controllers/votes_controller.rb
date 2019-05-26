class VotesController < ApplicationController
  before_action :set_post, only: :create
  before_action :set_vote, only: :update

  def create
    vote = @post.votes.create!(post_params.merge({user_id: current_user.id}))
    json_response(status: :created,
                    message: 'Successfully voted for post',
                    data: vote
                  )
  rescue => error
    json_error_response(message: error.message, errors: error)
  end

  def update
    if params[:vote_type] == @vote.vote_type && @vote.user.id == current_user.id
      raise ExceptionHandler::InvalidParams, "Multiple #{params[:vote_type]}s not allowed"
    end

    if @vote.update(post_params)
      json_response(message: 'Successfully voted for post', data: @vote)
    else
      json_error_response(message: error.message)
    end
  end

  private
    def set_post
      @post = Post.find(params[:post_id])
    end

    def set_vote
      @vote = Vote.find(params[:id])
    end

    def post_params
      params.permit(:vote_type)
    end
end
