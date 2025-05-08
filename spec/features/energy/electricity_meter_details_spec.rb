require "rails_helper"

describe "User can update electricity meters and usage", :js do
  include_context "with energy suppliers"

  specify "Adding electricity usage" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    visit new_energy_case_org_electricity_meter_path(case_id: case_organisation.energy_onboarding_case_id, org_id: case_organisation.onboardable_id)

    expect(page).to have_text("Electricity meter details")

    click_button "Save and continue"

    expect(page).to have_text("Enter the MPAN")

    expect(page).to have_text("Select whether the meter is half hourly")

    expect(page).to have_text("Enter the electricity usage")

    fill_in "Add an MPAN", with: "10"

    click_button "Save and continue"

    expect(page).to have_text("Enter a valid MPAN")

    fill_in "Add an MPAN", with: "testing text"

    click_button "Save and continue"

    expect(page).to have_text("Enter a valid MPAN")

    fill_in "Add an MPAN", with: "1234567890123"

    click_button "Save and continue"

    expect(page).not_to have_text("Enter a valid MPAN")

    choose "Yes"

    click_button "Save and continue"

    expect(page).to have_text("Enter the supply capacity")

    expect(page).to have_text("Enter the data aggregator")

    expect(page).to have_text("Enter the data collector")

    expect(page).to have_text("Enter the meter operator")

    fill_in "What is the supply capacity?", with: "1000"

    click_button "Save and continue"

    expect(page).not_to have_text("Enter the supply capacity")

    fill_in "Who is the data aggregator?", with: "123"

    click_button "Save and continue"

    expect(page).to have_text("Enter a valid data aggregator")

    fill_in "Who is the data aggregator?", with: "Test Aggregator"

    click_button "Save and continue"

    expect(page).not_to have_text("Enter a valid data aggregator")

    fill_in "Who is the data collector?", with: "123"

    click_button "Save and continue"

    expect(page).to have_text("Enter a valid data collector")

    fill_in "Who is the data collector?", with: "Test Collector"

    click_button "Save and continue"

    expect(page).not_to have_text("Enter a valid data collector")

    fill_in "Who is the meter operator?", with: "123"

    click_button "Save and continue"

    expect(page).to have_text("Enter a valid meter operator")

    fill_in "Who is the meter operator?", with: "Test Operator"

    click_button "Save and continue"

    expect(page).not_to have_text("Enter a valid meter operator")

    fill_in "Estimated annual electricity usage", with: "text"

    click_button "Save and continue"

    expect(page).to have_text("Enter a valid electricity usage")

    fill_in "Estimated annual electricity usage", with: "1000"

    click_button "Save and continue"

    expect(page).not_to have_text("Enter a valid electricity usage")
  end
end
