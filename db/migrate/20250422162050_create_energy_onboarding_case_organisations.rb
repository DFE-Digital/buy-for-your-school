class CreateEnergyOnboardingCaseOrganisations < ActiveRecord::Migration[7.2]
  def change
    create_table :energy_onboarding_case_organisations, id: :uuid do |t|
      t.references :energy_onboarding_case, null: true, type: :uuid
      t.references :support_case_organisation, null: true, type: :uuid
      t.references :support_organisation, null: true, type: :uuid
      t.references :support_establishment_group, null: true, type: :uuid
      t.integer :switching_energy_type
      t.timestamps
    end
  end
end
