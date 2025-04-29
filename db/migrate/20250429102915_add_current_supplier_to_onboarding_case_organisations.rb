class AddCurrentSupplierToOnboardingCaseOrganisations < ActiveRecord::Migration[7.2]
  def change
    add_column :energy_onboarding_case_organisations, :gas_current_supplier, :integer
    add_column :energy_onboarding_case_organisations, :gas_current_supplier_other, :string
    add_column :energy_onboarding_case_organisations, :gas_current_contract_end_date, :date

    add_column :energy_onboarding_case_organisations, :electric_current_supplier, :integer
    add_column :energy_onboarding_case_organisations, :electric_current_supplier_other, :string
    add_column :energy_onboarding_case_organisations, :electric_current_contract_end_date, :date
  end
end
