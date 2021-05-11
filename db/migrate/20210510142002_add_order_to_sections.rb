class AddOrderToSections < ActiveRecord::Migration[6.1]
  def change
    add_column :sections, :order, :integer
    add_index :sections, :order
  end
end
