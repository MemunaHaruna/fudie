class CategoriesController < ApplicationController
  before_action :require_admin, only: [:create, :update, :destroy]
  before_action :set_category, only: [:show, :update, :destroy]

  def index
    @categories = Category.all.page(params[:page]).per(params[:per_page] || 10)
    json_response(data: @categories)
  end

  def show
    json_response(data: @category)
  end

  def create
    @category = Category.new(category_params)

    if @category.save
      json_response(status: :created,
                      data: @category,
                      message: 'Successfully created new category'
                    )
    else
      json_error_response(errors: @category.errors)
    end
  end

  def update
    if @category.update(category_params)
      json_response(status: :created,
                      data: @category,
                      message: 'Successfully updated category'
                    )
    else
      render json: @category.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @category.destroy
    json_basic_response(message: 'Successfully deleted category.')
  end

  private
    def set_category
      @category = Category.find(params[:id])
    end

    def category_params
      params.require(:category).permit(:name)
    end
end
