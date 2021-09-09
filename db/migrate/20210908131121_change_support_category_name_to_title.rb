class ChangeSupportCategoryNameToTitle < ActiveRecord::Migration[6.1]
  def change
    rename_column :support_categories, :name, :title
    add_index :support_categories, :title, unique: true
  end
end
