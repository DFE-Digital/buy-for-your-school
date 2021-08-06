class ChangeJourneyStartedToFalse < ActiveRecord::Migration[6.1]
  def change
    change_column_default :journeys, :started, from: true, to: false
  end
end
