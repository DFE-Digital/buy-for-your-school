class AddNextEntryIdToPlan < ActiveRecord::Migration[6.0]
  def change
    add_column :plans, :next_entry_id, :string
  end
end
