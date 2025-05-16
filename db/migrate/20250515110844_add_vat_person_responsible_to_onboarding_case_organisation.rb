class AddVatPersonResponsibleToOnboardingCaseOrganisation < ActiveRecord::Migration[7.2]
  def change
    change_table :energy_onboarding_case_organisations, bulk: true do |t|
      t.column :vat_person_correct_details, :boolean
      t.column :vat_person_first_name, :string
      t.column :vat_person_last_name, :string
      t.column :vat_person_phone, :string
      t.column :vat_person_address, :jsonb
    end
  end
end
