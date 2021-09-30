class RemoveLastWorkedOnFromJourneys < ActiveRecord::Migration[6.1]
  def change
    remove_column :journeys, :last_worked_on, :datetime
  end
end
