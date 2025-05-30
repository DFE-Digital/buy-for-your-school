class AddLoaAgreedToOnboardingCaseOrganisation < ActiveRecord::Migration[7.2]
  def change
    add_column :energy_onboarding_case_organisations, :loa_agreed, :boolean, default: false
  end
end
