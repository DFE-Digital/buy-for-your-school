# frozen_string_literal: true

class Api::Contentful::CategoriesController < Api::Contentful::BaseController
  def changed
    contentful_category = GetCategory.new(category_entry_id: category_params[:id]).call

    category = Category.upsert(
      {
        title: contentful_category.title,
        description: contentful_category.description,
        liquid_template: contentful_category.combined_specification_template,
        contentful_id: contentful_category.id,
        slug: contentful_category.slug,
      },
      unique_by: :contentful_id,
      returning: %w[title description contentful_id slug liquid_template],
    )

    if category.first
      track_event("Contentful/Categories/Changed", slug: contentful_category.slug)

      render json: { status: "OK" }, status: :ok
    end
  end

private

  def category_params
    params.require(:sys).permit(:id)
  end
end
