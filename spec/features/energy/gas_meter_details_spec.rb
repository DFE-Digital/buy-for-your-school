require "rails_helper"

describe "User can update gas usage details", :js do
  let(:support_organisation) { create(:support_organisation, urn: 100_253) }
  let(:user) { create(:user, :many_supported_schools_and_groups) }
  let(:support_case) { create(:support_case, organisation: support_organisation) }
  let(:onboarding_case) { create(:onboarding_case, support_case:) }
  let(:case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case:, onboardable: support_organisation) }

  specify "Adding gas usage" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    visit new_energy_case_org_gas_meter_path(case_id: case_organisation.energy_onboarding_case_id, org_id: case_organisation.onboardable_id)

    expect(page).to have_text("Gas meter details")

    click_button "Save and continue"

    expect(page).to have_text("Enter the MPRN")

    expect(page).to have_text("Enter the gas usage")

    fill_in "Add a Meter Point Reference Number (MPRN)", with: "10"

    click_button "Save and continue"

    expect(page).to have_text("Enter a valid MPRN")

    fill_in "Add a Meter Point Reference Number (MPRN)", with: "testing text"

    click_button "Save and continue"

    expect(page).to have_text("Enter a valid MPRN")

    fill_in "Add a Meter Point Reference Number (MPRN)", with: "3938424403"

    click_button "Save and continue"

    expect(page).not_to have_text("Enter a valid MPRN")

    fill_in "Estimated annual gas usage for this meter, in kilowatt hours", with: "text"

    click_button "Save and continue"

    expect(page).to have_text("Enter a valid gas usage")

    fill_in "Estimated annual gas usage for this meter, in kilowatt hours", with: "1000"

    click_button "Save and continue"

    expect(page).not_to have_text("Enter a valid gas usage")
  end
end
