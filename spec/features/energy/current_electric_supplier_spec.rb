require "rails_helper"

describe "Current Electric supplier", :js do
  include_context "with energy suppliers"

  specify "Authenticating and seeing the current electric supplier" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    visit energy_case_electric_supplier_path(case_id: case_organisation.energy_onboarding_case_id)

    expect(page).to have_text("#{support_organisation.name}: Current contract details")
    expect(page).to have_text("Current electricity supplier")
    expected_suppliers.each do |supplier|
      expect(page).to have_text(supplier)
    end

    expect(page).to have_text("When does the contract end?")

    click_button "Save and continue"

    expect(page).to have_text("Please select current electric supplier")
    expect(page).to have_text("Please enter electric current contract end date")

    fill_in_valid_supplier_and_date("31", "12", "2035") # This date is out of range
    expect(page).to have_text("Please enter a date within the range of - 1 and + 5 years of the current date")

    fill_in_valid_supplier_and_date("32", "01", "2025") # This date is invalid date
    expect(page).to have_text("Please enter a valid electric current contract end date")

    fill_in_valid_supplier_and_date("29", "02", "2025") # This date is invalid non-leap year
    expect(page).to have_text("Please enter a valid electric current contract end date")

    fill_in_valid_supplier_and_date("31", "12", "2025")
    expect(page).not_to have_text("Current electricity supplier")
  end
end
