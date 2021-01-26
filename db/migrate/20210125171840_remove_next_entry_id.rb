class RemoveNextEntryId < ActiveRecord::Migration[6.1]
  def change
    remove_column(:journeys, :next_entry_id)
  end
end
