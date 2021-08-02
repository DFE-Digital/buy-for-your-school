# frozen_string_literal: true

class Api::Contentful::CategoriesController < Api::Contentful::BaseController
  def changed
    contentful_category = GetCategory.new(category_entry_id: category_params[:id]).call


    category = Category.find_or_create_by!(contentful_id: contentful_category.id) do |cat|
      cat.title = contentful_category.title
      cat.description = contentful_category.description
      cat.liquid_template = contentful_category.combined_specification_template
    end

    render json: { status: "OK" }, status: :ok if category
  end

private

  def category_params
    params.require(:sys).permit(:id)
  end
end
