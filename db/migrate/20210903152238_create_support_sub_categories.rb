class CreateSupportSubCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :support_sub_categories, id: :uuid do |t|
      t.uuid :category_id, null: false
      t.string :title, null: false
      t.string :description
      t.string :slug

      t.timestamps default: -> { "CURRENT_TIMESTAMP" }
    end
    add_index :support_sub_categories, :title, unique: true
    add_index :support_sub_categories, :slug, unique: true
  end
end
