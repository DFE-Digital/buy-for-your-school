class CreateRequestForHelpCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :request_for_help_categories, id: :uuid do |t|
      t.string :title, null: false
      t.text :description
      t.string :slug, index: { unique: false }
      t.references :parent, foreign_key: { to_table: :request_for_help_categories }, type: :uuid
      t.references :support_category, foreign_key: { to_table: :support_categories }, type: :uuid
      t.boolean :archived, default: false, null: false
      t.datetime :archived_at

      t.timestamps
    end
  end
end
