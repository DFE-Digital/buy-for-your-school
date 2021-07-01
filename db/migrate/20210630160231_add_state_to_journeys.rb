class AddStateToJourneys < ActiveRecord::Migration[6.1]
  def change
    add_column :journeys, :state, :integer, default: 0
  end
end
