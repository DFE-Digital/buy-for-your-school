class AddSlugsToExistingCategories < ActiveRecord::Migration[6.1]
  def up
    return if Category.where(slug: nil).none? || Category.where(description: nil).none?

    categories = Category.where(slug: nil)
    categories.each do |category|
      contentful_category = Content::Client.new.by_id(category.contentful_id)
      next if contentful_category.nil?

      category.update!(
        slug: contentful_category.slug,
        description: contentful_category.description,
      )
    end

    categories = Category.where(description: nil)
    categories.each do |category|
      contentful_category = Content::Client.new.by_id(category.contentful_id)
      category.update!(description: contentful_category.description) unless contentful_category.nil?
    end
  end

  def down; end
end
