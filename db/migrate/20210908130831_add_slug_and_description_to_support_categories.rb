class AddSlugAndDescriptionToSupportCategories < ActiveRecord::Migration[6.1]
  def change
    add_column :support_categories, :slug, :string
    add_index :support_categories, :slug, unique: true
    add_column :support_categories, :description, :string
  end
end
