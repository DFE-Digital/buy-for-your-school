class CreateEnergyOnboardingCaseOrganisations < ActiveRecord::Migration[7.2]
  def change
    create_table :energy_onboarding_case_organisations, id: :uuid do |t|
      t.references :energy_onboarding_case, foreign_key: true, type: :uuid
      t.uuid :onboardable_id
      t.string :onboardable_type
      t.integer :switching_energy_type
      t.timestamps

      t.index %i[onboardable_type onboardable_id]
    end
  end
end
