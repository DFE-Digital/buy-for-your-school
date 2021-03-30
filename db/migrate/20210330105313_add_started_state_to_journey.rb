class AddStartedStateToJourney < ActiveRecord::Migration[6.1]
  def change
    add_column :journeys, :started, :boolean, default: true
    add_index :journeys, :started
  end
end
