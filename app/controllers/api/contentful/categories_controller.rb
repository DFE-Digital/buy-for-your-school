# frozen_string_literal: true

require "pry"

class Api::Contentful::CategoriesController < Api::Contentful::BaseController
  def changed
    # binding.pry
    contentful_category = GetCategory.new(category_entry_id: category_params[:id]).call

    category = Category.upsert({
      title: contentful_category.title,
      description: contentful_category.description,
      liquid_template: contentful_category.combined_specification_template,
      contentful_id: contentful_category.id,
      slug: contentful_category.slug,
    },
    unique_by: :contentful_id,
    returning: "title")

    unless category.empty?
      render json: { status: "OK" }, status: :ok
      Rollbar.info("Processed published webhook event for Contentful Category", category: category.to_a[0]["title"])
    end
  end

private

  def category_params
    params.require(:sys).permit(:id)
  end
end
