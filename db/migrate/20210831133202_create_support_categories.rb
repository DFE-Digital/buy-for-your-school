class CreateSupportCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :support_categories, id: :uuid do |t|
      t.string :name, null: false
      t.timestamps
    end
  end
end
