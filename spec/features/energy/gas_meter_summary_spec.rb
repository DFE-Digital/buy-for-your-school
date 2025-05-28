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

    visit energy_case_org_gas_single_multi_path(case_id: case_organisation.energy_onboarding_case_id, org_id: case_organisation.onboardable_id)

    choose "Multi meter"

    click_button "Save and continue"

    expect(page).to have_text("Gas meter details")

    fill_in "Add a Meter Point Reference Number (MPRN)", with: "3938424403"

    fill_in "Estimated annual gas usage for this meter, in kilowatt hours", with: "1000"

    click_button "Save and continue"

    expect(page).to have_text("3938424403")

    expect(page).to have_text("1000")

    click_link "Change"

    fill_in "Add a Meter Point Reference Number (MPRN)", with: "3938424600"

    fill_in "Estimated annual gas usage for this meter, in kilowatt hours", with: "2000"

    click_button "Save and continue"

    expect(page).to have_text("3938424600")

    expect(page).to have_text("2000")

    click_link "Add another MPRN"

    fill_in "Add a Meter Point Reference Number (MPRN)", with: "6543210"

    fill_in "Estimated annual gas usage for this meter, in kilowatt hours", with: "3000"

    click_button "Save and continue"

    expect(page).to have_text("6543210")

    within(:xpath, "//tr[contains(., '6543210')]") do
      click_link "Remove"
    end

    expect(page).to have_text("Are you sure you want to remove this MPRN?")

    click_link "Remove MPRN"

    expect(page).to have_text("MPRN successfully removed")
  end
end
