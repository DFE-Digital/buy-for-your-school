class CategoriesController < ApplicationController
  def index
    populate_categories if Category.none?
    @categories = Category.all.order(:title)
  end

private

  # On an initial run the `categories` table will be empty
  #
  def populate_categories
    ContentfulConnector.new.by_type("category").each do |entry|
      contentful_category = GetCategory.new(category_entry_id: entry.id).call

      # TODO: create category service
      Category.find_or_create_by!(contentful_id: contentful_category.id) do |category|
        category.title = contentful_category.title
        # TODO: data migration to persist the slug
        # category.slug = contentful_category.slug
        category.description = contentful_category.description
        category.liquid_template = contentful_category.combined_specification_template
      end
    end
  end
end
