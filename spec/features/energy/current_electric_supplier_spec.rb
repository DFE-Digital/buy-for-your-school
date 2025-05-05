require "rails_helper"

describe "Current Electric supplier", :js do
  let(:support_organisation) { create(:support_organisation, urn: 100_253) }
  let(:user) { create(:user, :many_supported_schools_and_groups) }
  let(:support_case) { create(:support_case, organisation: support_organisation) }
  let(:onboarding_case) { create(:onboarding_case, support_case:) }
  let(:case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case:, onboardable: support_organisation) }

  specify "Authenticating and seeing the current electric supplier" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    visit energy_case_electric_supplier_path(case_id: case_organisation.energy_onboarding_case_id)

    expect(page).to have_text("#{support_organisation.name}: Current contract details")
    expect(page).to have_text("Current electricity supplier")

    expect(page).to have_text("British Gas")
    expect(page).to have_text("EDF Energy")
    expect(page).to have_text("E.ON Next")
    expect(page).to have_text("Scotish Power")
    expect(page).to have_text("OVO Energy")
    expect(page).to have_text("Octopus Energy")
    expect(page).to have_text("Other")

    expect(page).to have_text("When does the contract end?")

    click_button "Save and continue"

    expect(page).to have_text("Please select current electric supplier")
    expect(page).to have_text("Please enter electric current contract end date")

    choose "British Gas"

    fill_in "Day", with: "31"
    fill_in "Month", with: "12"
    fill_in "Year", with: "2025"

    click_button "Save and continue"
    # TODO: Add a check for the redirect to the next page
  end
end
