require "rails_helper"

describe "User can update electricity meters and usage", :js do
  include_context "with energy suppliers"

  specify "Adding electricity usage" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    visit new_energy_case_org_electricity_meter_path(onboarding_case, case_organisation)

    expect(page).to have_text("Electricity meter details")

    click_button "Save and continue"

    expect(page).to have_text("Enter an MPAN number")

    expect(page).to have_text("Select whether your meter is half hourly or not")

    expect(page).to have_text("Enter the estimated annual usage in kilowatt hours")

    fill_in "Add an MPAN", with: "10"

    click_button "Save and continue"

    expect(page).to have_text("The MPAN must be in the correct format and 13 numbers long")

    fill_in "Add an MPAN", with: "testing text"

    click_button "Save and continue"

    expect(page).to have_text("The MPAN must be in the correct format and 13 numbers long")

    fill_in "Add an MPAN", with: "1234567890123"

    click_button "Save and continue"

    expect(page).not_to have_text("The MPAN must be in the correct format and 13 numbers long")

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

    expect(page).to have_text("Enter a valid estimated annual usage in kilowatt hours")

    fill_in "Estimated annual electricity usage", with: "1000"

    click_button "Save and continue"

    expect(page).not_to have_text("Enter a valid estimated annual usage in kilowatt hours")

    visit new_energy_case_org_electricity_meter_path(onboarding_case, case_organisation)

    fill_in "Add an MPAN", with: "1234567890123"

    click_button "Save and continue"

    expect(page).to have_text("This MPAN is already registered with Energy for Schools. Please contact dfe-energy.services-team@education.gov.uk to resolve the matter")

    fill_in "Add an MPAN", with: "1234567890124"

    click_button "Save and continue"

    expect(page).not_to have_text("This MPAN is already registered with Energy for Schools. Please contact dfe-energy.services-team@education.gov.uk to resolve the matter")
  end
end
