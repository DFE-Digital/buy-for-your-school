class CreateCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :categories, id: :uuid do |t|
      t.string :title, null: false
      t.string :description
      t.string :contentful_id, null: false
      t.jsonb :liquid_template, null: false
      t.timestamps
    end
  end
end
