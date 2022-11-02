class MoveSessionIdToUserJourneys < ActiveRecord::Migration[7.0]
  def change
    remove_column :user_journey_steps, :session_id, :string
    add_column :user_journeys, :session_id, :string
  end
end
