class DropSubCategoriesTable < ActiveRecord::Migration[6.1]
  def change
    drop_table :support_sub_categories do |t|
      t.uuid "category_id", null: false
      t.string "title", null: false
      t.string "description"
      t.string "slug"
      t.datetime "created_at", precision: 6, default: -> { "CURRENT_TIMESTAMP" }, null: false
      t.datetime "updated_at", precision: 6, default: -> { "CURRENT_TIMESTAMP" }, null: false
      t.index %w[slug], name: "index_support_sub_categories_on_slug", unique: true
      t.index %w[title], name: "index_support_sub_categories_on_title", unique: true
    end
  end
end
