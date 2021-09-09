class AddUniqueRefIndexSupportCase < ActiveRecord::Migration[6.1]
  def change
    add_index :support_cases, :ref, unique: true
  end
end
