class CreateUserJourneyStep < ActiveRecord::Migration[7.0]
  def change
    create_table :user_journey_steps, id: :uuid do |t|
      t.uuid :session_id
      t.integer :product_section
      t.string :step_description
      t.references :user_journey, foreign_key: { to_table: :user_journeys }, type: :uuid

      t.timestamps
    end
  end
end
