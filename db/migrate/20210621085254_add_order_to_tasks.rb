class AddOrderToTasks < ActiveRecord::Migration[6.1]
  def change
    add_column :tasks, :order, :integer
    add_index :tasks, :order
  end
end
