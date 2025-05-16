class AddBillingPreferencesToOnboardingCaseOrganisation < ActiveRecord::Migration[7.2]
  def change
    change_table :energy_onboarding_case_organisations, bulk: true do |t|
      t.column :billing_payment_method, :integer
      t.column :billing_payment_terms, :integer
      t.column :billing_invoicing_method, :integer
      t.column :billing_invoicing_email, :string
    end
  end
end
