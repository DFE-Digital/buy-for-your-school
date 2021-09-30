class MakeContentfulIdUniqueInCategories < ActiveRecord::Migration[6.1]
  def change
    add_index :categories, :contentful_id, unique: true
  end
end
