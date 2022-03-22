class AddFinishedAtToJourney < ActiveRecord::Migration[6.1]
  def change
    add_column :journeys, :finished_at, :datetime
  end
end
