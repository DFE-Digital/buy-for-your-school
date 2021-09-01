class AddSlugsToExistingCategories < ActiveRecord::Migration[6.1]
  def up
    return if Category.where(slug: nil).none?

    categories = Category.where(slug: nil)
    categories.each do |category|
      contentful_category = Content::Client.new.by_id(category.contentful_id)
      category.update!(slug: contentful_category.slug) unless contentful_category.nil?
    end
  end

  def down; end
end
