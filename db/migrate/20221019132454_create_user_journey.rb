class CreateUserJourney < ActiveRecord::Migration[7.0]
  def change
    create_table :user_journeys, id: :uuid do |t|
      t.integer :status
      t.references :case, foreign_key: { to_table: :support_cases }, type: :uuid
      t.string :referral_campaign

      t.timestamps
    end
  end
end
