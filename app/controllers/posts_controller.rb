class PostsController < ApplicationController
  before_action :set_post, only: [:show, :update, :destroy]

  def index
    posts = Post.published
    json_response(status: :ok, data: posts)
  end

  def drafts
    posts = current_user.posts.draft
    json_response(status: :ok, data: posts)
  end

  def private
    @posts = current_user.posts.private
    json_response(status: :ok, data: posts)
  end

  def show
    json_response(status: :ok, data: @post)
  end

  def create
    @post = Post.new(post_params)
    # logic for updating a post's depth and parent_id

    if @post.save
      json_response(status: :created, data: @post, message: 'Successfully created new post')
    else
      json_error_response(errors: @post.errors)
    end
  end

  def update
    if @post.update(post_update_params)
      json_response(status: :ok, object: @post, message: 'Successfully created new post')
    else
      json_error_response(errors: @post.errors)
    end
  end

  def destroy
    @post.destroy
    json_response(message: 'Successfully deleted Post')
  end

  private
    def set_post
      @post = Post.find(params[:id])
    end

    def post_params
      params.permit(:title, :body, :user_id, :state)
    end

    def post_update_params
      params.permit(:title, :body, :state)
    end
end
