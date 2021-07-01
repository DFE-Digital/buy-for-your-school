class RemoveContentfulIdFromJourneys < ActiveRecord::Migration[6.1]
  def change
    remove_column :journeys, :contentful_id, :string
  end
end
