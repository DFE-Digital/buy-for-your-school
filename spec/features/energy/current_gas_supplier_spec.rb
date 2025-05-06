require "rails_helper"

describe "Current Gas supplier", :js do
  include_context "with energy suppliers"

  specify "Authenticating and seeing the current gas supplier" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    visit energy_case_gas_supplier_path(case_id: case_organisation.energy_onboarding_case_id)

    expect(page).to have_text("#{support_organisation.name}: Current contract details")
    expect(page).to have_text("Current gas supplier")
    expected_suppliers.each do |supplier|
      expect(page).to have_text(supplier)
    end
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
