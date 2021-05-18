class AddOrderToSteps < ActiveRecord::Migration[6.1]
  def change
    add_column :steps, :order, :integer
    add_index :steps, :order
  end
end
