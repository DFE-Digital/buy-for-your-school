class RemoveRefIndexSupportCase < ActiveRecord::Migration[6.1]
  def change
    remove_index :support_cases, :ref
  end
end
