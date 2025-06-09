class AddVatRateChargeToOnboardingCaseOrganisation < ActiveRecord::Migration[7.2]
  def change
    change_table :energy_onboarding_case_organisations, bulk: true do |t|
      t.column :vat_rate, :integer
      t.column :vat_lower_rate_percentage, :integer
      t.column :vat_lower_rate_reg_no, :string
    end
  end
end
