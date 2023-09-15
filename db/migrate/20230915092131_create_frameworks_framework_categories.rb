class CreateFrameworksFrameworkCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :frameworks_framework_categories, id: :uuid do |t|
      t.uuid :support_category_id, null: false, foreign_key: true
      t.uuid :framework_id, null: false, foreign_key: true

      t.timestamps
    end

    remove_column :frameworks_frameworks, :support_category_id, :uuid
  end
end
