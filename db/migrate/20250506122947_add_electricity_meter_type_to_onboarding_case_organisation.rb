class AddElectricityMeterTypeToOnboardingCaseOrganisation < ActiveRecord::Migration[7.2]
  def change
    add_column :energy_onboarding_case_organisations, :electricity_meter_type, :integer
  end
end
