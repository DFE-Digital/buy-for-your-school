class AddElectricityBillConsolidationToOnboardingCaseOrganisation < ActiveRecord::Migration[7.2]
  def change
    add_column :energy_onboarding_case_organisations, :electricity_bill_consolidation, :boolean
  end
end
