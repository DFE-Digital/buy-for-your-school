class AddElectricityBillConsolidationToOnboardingCaseOrganisation < ActiveRecord::Migration[7.2]
  def change
    add_column :energy_onboarding_case_organisations, :is_electric_bill_consolidated, :boolean
  end
end
