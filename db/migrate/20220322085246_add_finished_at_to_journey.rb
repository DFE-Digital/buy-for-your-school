class AddFinishedAtToJourney < ActiveRecord::Migration[6.1]
  def change
    add_column :journeys, :finsihed_at, :datetime
  end
end
