class CategoriesController < ApplicationController
  def index
    populate_categories if Category.none?
    categories = Category.where.not(contentful_id: 0).order(:title)
    @categories = categories.map { |c| CategoryPresenter.new(c) }
  end

private

  # CMS: initialise Content::Client in the base controller
  def client
    Content::Client.new
  end

  # On an initial run the `categories` table will be empty
  #
  def populate_categories
    client.by_type(:category).each do |entry|
      contentful_category = GetCategory.new(category_entry_id: entry.id).call

      # TODO: create category service
      Category.find_or_create_by!(contentful_id: contentful_category.id) do |category|
        category.title = contentful_category.title
        category.description = contentful_category.description
        category.liquid_template = contentful_category.combined_specification_template
        category.slug = contentful_category.slug
      end
    end
  end
end
