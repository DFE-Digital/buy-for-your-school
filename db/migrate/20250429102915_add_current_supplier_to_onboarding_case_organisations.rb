class AddCurrentSupplierToOnboardingCaseOrganisations < ActiveRecord::Migration[7.2]
  def change
    add_column :energy_onboarding_case_organisations, :current_supplier, :integer, null: true
    add_column :energy_onboarding_case_organisations, :other_supplier, :string
  end
end
