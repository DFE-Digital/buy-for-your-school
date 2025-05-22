class CreateEnergyOnboardingCases < ActiveRecord::Migration[7.2]
  def change
    create_table :energy_onboarding_cases, id: :uuid do |t|
      t.references :support_case, foreign_key: true, type: :uuid
      t.boolean :are_you_authorised

      t.timestamps
    end
  end
end
