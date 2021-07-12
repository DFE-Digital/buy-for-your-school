class CategoriesController < ApplicationController
  def index
    @categories = Category.all.order(:title)
  end

  def new_spec
    category_id = params[:category_id]
    return redirect_to categories_path if category_id.nil?

    redirect_to new_journey_path(category_id)
  end
end
