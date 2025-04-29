class AddCurrentSupplierToOnboardingCaseOrganisations < ActiveRecord::Migration[7.2]
  def change
    change_table :energy_onboarding_case_organisations, bulk: true do |t|
      t.integer :gas_current_supplier
      t.string :gas_current_supplier_other
      t.date :gas_current_contract_end_date

      t.integer :electric_current_supplier
      t.string :electric_current_supplier_other
      t.date :electric_current_contract_end_date
    end
  end
end
