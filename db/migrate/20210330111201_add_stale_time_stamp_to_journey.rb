class AddStaleTimeStampToJourney < ActiveRecord::Migration[6.1]
  def change
    add_column :journeys, :last_worked_on, :datetime
    add_index :journeys, :last_worked_on
  end
end
