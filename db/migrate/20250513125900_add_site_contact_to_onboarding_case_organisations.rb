class AddSiteContactToOnboardingCaseOrganisations < ActiveRecord::Migration[7.2]
  def change
    change_table :energy_onboarding_case_organisations, bulk: true do |t|
      t.string :site_contact_first_name
      t.string :site_contact_last_name
      t.string :site_contact_email
      t.string :site_contact_phone
    end
  end
end
