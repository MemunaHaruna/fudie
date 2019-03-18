class PostsController < ApplicationController
  before_action :set_post, only: [:show, :update, :destroy]

  def index
    posts = Post.posts_only.published
    json_response(status: :ok, data: posts)
  end

  def public_posts_per_user
    posts = Post.where(user_id: params[:user_id]).posts_only.published
    json_response(status: :ok, data: posts)
  end

  def drafts
    posts = current_user.posts.posts_only.draft
    json_response(status: :ok, data: posts)
  end

  def hidden
    posts = current_user.posts.posts_only.hidden
    json_response(status: :ok, data: posts)
  end

  def show
    if @post.published? || @post.user_id == current_user.id
      json_response(status: :ok, data: @post)
    else
      raise ExceptionHandler::UnauthorizedUser, 'You are not authorised to view this post'
    end
  end

  def create
    @post = Post.new(post_params)

    # logic for updating a post's depth
    @post.set_depth
    if @post.save
      @post.save_categories(params[:category_ids]) if params[:category_ids]
      json_response(status: :created, data: @post, message: 'Post created successfully')
    else
      json_error_response(errors: @post.errors)
    end
  end

  def update
    if @post.user_id != current_user.id
      raise ExceptionHandler::UnauthorizedUser, 'You are not authorized to perform this action'
    end


    if @post.update(post_update_params)
      @post.update_categories(params[:category_ids]) if params[:category_ids]
      json_response(data: @post, message: 'Post updated successfully')
    else
      json_error_response(errors: @post.errors)
    end
  end

  def destroy
    if @post.user_id != current_user.id
      raise ExceptionHandler::UnauthorizedUser, 'You are not authorized to perform this action'
    end

    @post.destroy
    json_response(message: 'Post deleted successfully', status: :no_content)
  end

  private
    def set_post
      @post = Post.find(params[:id])
    end

    def post_params
      params.permit(:title, :body, :user_id, :state, :parent_id)
    end

    def post_update_params
      params.permit(:title, :body, :state)
    end
end
