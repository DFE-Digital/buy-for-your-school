require "rails_helper"

describe "User can update gas usage details", :js do
  include_context "with energy suppliers"
  specify "Adding gas usage" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    visit new_energy_case_org_gas_meter_path(onboarding_case, case_organisation)

    expect(page).to have_text("Gas meter details")

    click_button "Save and continue"

    expect(page).to have_text("Enter a Meter Point Reference Number")

    expect(page).to have_text("Enter the estimated annual usage in kilowatt hours")

    fill_in "Add a Meter Point Reference Number (MPRN)", with: "10"

    click_button "Save and continue"

    expect(page).to have_text("The MPRN must be in the correct format and between 6 and 12 numbers long")

    fill_in "Add a Meter Point Reference Number (MPRN)", with: "testing text"

    click_button "Save and continue"

    expect(page).to have_text("The MPRN must be in the correct format and between 6 and 12 numbers long")

    fill_in "Add a Meter Point Reference Number (MPRN)", with: "3938424403"

    click_button "Save and continue"

    expect(page).not_to have_text("The MPRN must be in the correct format and between 6 and 12 numbers long")

    fill_in "Estimated annual gas usage for this meter, in kilowatt hours", with: "text"

    click_button "Save and continue"

    expect(page).to have_text("Enter a valid estimated annual usage in kilowatt hours")

    fill_in "Estimated annual gas usage for this meter, in kilowatt hours", with: "1000"

    click_button "Save and continue"

    expect(page).not_to have_text("Enter a valid estimated annual usage in kilowatt hours")

    visit new_energy_case_org_gas_meter_path(onboarding_case, case_organisation)

    fill_in "Add a Meter Point Reference Number (MPRN)", with: "3938424403"

    click_button "Save and continue"

    expect(page).to have_text("This MPRN is already registered with Energy for Schools. Please contact dfe-energy.services-team@education.gov.uk to resolve the matter")

    fill_in "Add a Meter Point Reference Number (MPRN)", with: "3938424404"

    click_button "Save and continue"

    expect(page).not_to have_text("This MPRN is already registered with Energy for Schools. Please contact dfe-energy.services-team@education.gov.uk to resolve the matter")
  end
end
