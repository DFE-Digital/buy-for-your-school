require "rails_helper"

describe "Current Gas supplier", :js do
  let(:user) { create(:user) }
  let(:support_case) { create(:support_case) }
  let(:onboarding_case) { create(:onboarding_case, support_case:) }
  let(:energy_onboarding_case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case:) }

  specify "Authenticating and seeing the current gas supplier" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    visit energy_gas_supplier_path(id: energy_onboarding_case_organisation.energy_onboarding_case_id)

    expect(page).to have_text("About your schools: Current contract details")
    expect(page).to have_text("Current gas supplier")

    expect(page).to have_text("British Gas")
    expect(page).to have_text("EDF Energy")
    expect(page).to have_text("E.ON Next")
    expect(page).to have_text("Scotish Power")
    expect(page).to have_text("OVO Energy")
    expect(page).to have_text("Octopus Energy")
    expect(page).to have_text("Other")

    expect(page).to have_text("When does the contract end?")

    click_button "Save and continue"

    expect(page).to have_text("Please select current gas supplier")
    expect(page).to have_text("Please enter gas current contract end date")

    choose "Scotish Power"

    fill_in "Day", with: "10"
    fill_in "Month", with: "5"
    fill_in "Year", with: "2025"

    click_button "Save and continue"
    # TODO: Add a check for the redirect to the next page
  end
end
