class PostsController < ApplicationController
  before_action :set_post, only: [:show, :update, :destroy, :recover]

  def index
    posts = Post.search(search_params[:query], filter_options).records
    posts = posts.page(params[:page]).per(params[:per_page] || 10)
    json_response(status: :ok, data: posts)
  end

  def public_posts_per_user
    options = filter_options.merge(user_id: params[:id])

    posts = Post.search(search_params[:query], options).records
    posts = posts.page(params[:page]).per(params[:per_page] || 10)
    json_response(status: :ok, data: posts)
  end

  def drafts
    options = filter_options.merge(state: 'draft', user_id: current_user.id)

    posts = Post.search(search_params[:query], options).records
    posts = posts.page(params[:page]).per(params[:per_page] || 10)
    json_response(status: :ok, data: posts)
  end

  def hidden
    options = filter_options.merge(state: 'hidden', user_id: current_user.id)

    posts = Post.search(search_params[:query], options).records
    posts = posts.page(params[:page]).per(params[:per_page] || 10)
    json_response(status: :ok, data: posts)
  end

  def show
    if ((@post.published? || @post.user_id == current_user.id) && @post.active)
      json_response(status: :ok, data: @post)
    else
      raise ExceptionHandler::UnauthorizedUser, 'You are not authorised to view this post'
    end
  end

  def create
    @post = current_user.posts.new(post_params)

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
    if ((@post.user_id != current_user.id) || !@post.active)
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
    if (@post.user_id != current_user.id || @post.deactivated_by_admin)
      raise ExceptionHandler::UnauthorizedUser, 'You are not authorized to perform this action'
    end

    @post.soft_destroy
    json_basic_response(message: 'Post deleted successfully.')
  end

  def recover
    if (@post.user_id != current_user.id || @post.deactivated_by_admin)
      raise ExceptionHandler::UnauthorizedUser, 'You are not authorized to perform this action'
    end

    @post.recover
    json_basic_response(message: 'Post restored successfully.')
  end

  private
    def set_post
      @post = Post.find(params[:id])
    end

    def post_params
      params.permit(:title, :body, :state, :parent_id)
    end

    def post_update_params
      params.permit(:title, :body, :state)
    end

    def search_params
      params.permit(:query)
    end

    def filter_options
      { state: 'published', posts_only: true, active: true }
    end
end
