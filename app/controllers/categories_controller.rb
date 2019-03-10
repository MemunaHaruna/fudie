class CategoriesController < ApplicationController
  before_action :require_admin
  before_action :set_category, only: [:show, :update, :destroy]

  def index
    @categories = Category.all
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
    json_response(data: @category, message: 'Successfully deleted bookmark')
  end

  private
    def set_category
      @category = Category.find(params[:id])
    end

    def category_params
      params.require(:category).permit(:name)
    end
end