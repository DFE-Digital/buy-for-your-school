# Create categories to allow different specification types
#
class CreateCategory
  extend Dry::Initializer

  # @!attribute [r] contentful_category
  # @return [Contentful::Entry]
  option :contentful_category

  # @return [Category]
  def call
    Category.find_or_create_by!(contentful_id: contentful_category.id) do |category|
      category.title = contentful_category.title
      category.description = contentful_category.description
      category.liquid_template = contentful_category.combined_specification_template
      category.slug = contentful_category.slug
    end
  end
end
