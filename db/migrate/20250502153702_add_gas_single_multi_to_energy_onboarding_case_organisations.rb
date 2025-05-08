class AddGasSingleMultiToEnergyOnboardingCaseOrganisations < ActiveRecord::Migration[7.2]
  def change
    add_column :energy_onboarding_case_organisations, :gas_single_multi, :integer
  end
end
