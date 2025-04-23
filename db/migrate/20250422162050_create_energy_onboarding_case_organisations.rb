class CreateEnergyOnboardingCaseOrganisations < ActiveRecord::Migration[7.2]
  def change
    create_table :energy_onboarding_case_organisations, id: :uuid do |t|
      t.references :energy_onboarding_case, null: false, type: :uuid
      t.references :support_case_organisation, null: false, type: :uuid
      t.integer :switching_energy_type

      t.timestamps
    end
  end
end
