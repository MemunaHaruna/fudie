class BookmarksController < ApplicationController
  before_action :set_bookmark, only: [:show, :update, :destroy]
  before_action :set_user, only: :index

  def index
    @bookmarks = @user.bookmarks.page(params[:page]).per(params[:per_page] || 10)
    json_response(data: @bookmarks)
  end

  def show
    json_response(data: @bookmark)
  end

  def create
    @bookmark = current_user.bookmarks.new(bookmark_params)

    if @bookmark.save
      json_response(status: :created, data: @bookmark, message: 'Successfully created new bookmark')
    else
      json_error_response(errors: @bookmark.errors)
    end
  end

  def update
    if @bookmark.user_id != current_user.id
      raise ExceptionHandler::UnauthorizedUser, 'You are not authorized to perform this action'
    end

    if @bookmark.update(bookmark_params)
      json_response(data: @bookmark, message: 'Successfully updated bookmark')

    else
      json_error_response(errors: @bookmark.errors)
    end
  end

  def destroy
    if @bookmark.user_id != current_user.id
      raise ExceptionHandler::UnauthorizedUser, 'You are not authorized to perform this action'
    end

    @bookmark.destroy
    json_basic_response(message: 'Successfully deleted bookmark')
  end

  private
    def set_bookmark
      @bookmark = Bookmark.find(params[:id])
    end

    def set_user
      @user = User.find(params[:user_id])
    end

    def bookmark_params
      params.permit(:user_id, :post_id)
    end
end
