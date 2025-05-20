class AddBillingAddressConfirmationToOnboardingCaseOrganisation < ActiveRecord::Migration[7.2]
  def change
    change_table :energy_onboarding_case_organisations, bulk: true do |t|
      t.column :billing_invoice_address, :jsonb
      t.column :billing_invoice_address_source_id, :string
    end
  end
end
