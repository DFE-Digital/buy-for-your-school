class AddSubmittedAtToEnergyOnboardingCase < ActiveRecord::Migration[7.2]
  def change
    add_column :energy_onboarding_cases, :submitted_at, :datetime
  end
end
