class AddNewEmailSentFieldsToEnergyOnboardingCases < ActiveRecord::Migration[7.2]
  def change
    change_table :energy_onboarding_cases, bulk: true do |t|
      t.column :form_started_email_sent, :boolean, default: false
      t.column :form_submitted_email_sent, :boolean, default: false
    end
  end
end
