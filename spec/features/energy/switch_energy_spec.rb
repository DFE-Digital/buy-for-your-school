require "rails_helper"

describe "User can update energy type", :js do
  let(:user) { create(:user) }
  let(:support_case) { create(:support_case) }
  let(:onboarding_case) { create(:onboarding_case, support_case:) }
  let(:energy_onboarding_case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case:) }

  specify "Verify the single school fuel selection" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    visit energy_switch_energy_path(id: energy_onboarding_case_organisation.energy_onboarding_case_id)

    expect(page).to have_text("Are you switching electricity, gas or both?")

    expect(page).to have_text("Electricity only")

    expect(page).to have_text("Gas only")

    expect(page).to have_text("Gas and electricity")
  end
end
