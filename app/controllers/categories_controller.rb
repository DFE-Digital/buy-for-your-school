class CategoriesController < ApplicationController
  def index
    @categories = Category.all.order(:title)
    @category_input = CategoryInput.new
  end

  def new_spec
    @category_input = get_category_params
    if @category_input.valid?
      redirect_to new_journey_path(@category_input.category_id)
    else
      redirect_to categories_path
    end
  end

  def new_journey_mapper
    @category_input = get_category_params
    if @category_input.valid?
      redirect_to new_journey_map_path(@category_input.category_id)
    else
      redirect_to journey_maps_path
    end
  end

  def get_category_params
    category_params = params.require(:category_input).permit(:category_id)
    category_input = CategoryInput.new
    category_input.assign_attributes(category_params)
    category_input
  end
end
