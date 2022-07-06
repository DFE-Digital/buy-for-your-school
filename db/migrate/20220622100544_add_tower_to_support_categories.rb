class AddTowerToSupportCategories < ActiveRecord::Migration[6.1]
  def change
    add_column :support_categories, :tower, :string
  end
end
