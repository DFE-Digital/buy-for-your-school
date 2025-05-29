require "rails_helper"

describe "User can update electricity meters and usage", :js do
  include_context "with energy suppliers"

  specify "Adding electricity usage" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    visit energy_case_org_electricity_meter_type_path(case_id: case_organisation.energy_onboarding_case_id, org_id: case_organisation.onboardable_id)

    choose "Multi meter"

    click_button "Save and continue"

    expect(page).to have_text("Electricity meter details")

    fill_in "Add an MPAN", with: "1234567890123"

    choose "No"

    fill_in "Estimated annual electricity usage", with: "1000"

    click_button "Save and continue"

    expect(page).to have_text("1234567890123")

    expect(page).to have_text("1000")

    click_link "Change"

    fill_in "Add an MPAN", with: "1234567890999"

    fill_in "Estimated annual electricity usage", with: "2000"

    click_button "Save and continue"

    expect(page).to have_text("1234567890999")
    expect(page).to have_text("2000")
    expect(page).to have_link("Discard and go to task list", href: energy_case_tasks_path(case_id: onboarding_case.id))

    click_link "Add another MPAN"

    fill_in "Add an MPAN", with: "1234567890555"

    choose "No"

    fill_in "Estimated annual electricity usage", with: "3000"

    click_button "Save and continue"

    expect(page).to have_text("1234567890555")

    within(:xpath, "//tr[contains(., '1234567890555')]") do
      click_link "Remove"
    end

    expect(page).to have_text("Are you sure you want to remove this MPAN?")

    click_link "Remove MPAN"

    expect(page).to have_text("MPAN successfully removed")
  end
end
