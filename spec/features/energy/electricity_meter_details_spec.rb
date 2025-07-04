require "rails_helper"

describe "User can update electricity meters and usage", :js do
  include_context "with energy suppliers"

  let!(:another_organisation) { create(:support_organisation, urn: 100_254) }
  let!(:another_support_case) { create(:support_case, organisation: another_organisation, state: :on_hold) }
  let!(:another_onboarding_case) { create(:onboarding_case, support_case: another_support_case) }
  let!(:another_case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case: another_onboarding_case, onboardable: another_organisation) }
  let!(:electricity_meter) { create(:energy_electricity_meter, :with_valid_data, mpan: "1234567890555", energy_onboarding_case_organisation_id: another_case_organisation.id) }

  before do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)
  end

  specify "Adding electricity usage" do
    visit new_energy_case_org_electricity_meter_path(onboarding_case, case_organisation)

    expect(page).to have_text("Electricity meter details")
    expect(page).to have_link("Discard and go to task list", href: energy_case_tasks_path(case_id: onboarding_case.id))

    click_button "Save and continue"

    expect(page).to have_text("Enter an MPAN")

    expect(page).to have_text("Select whether your meter is half hourly or not")

    expect(page).to have_text("Enter the estimated annual usage in kilowatt hours")

    fill_in "Add an MPAN", with: "10"

    click_button "Save and continue"

    expect(page).to have_text("Enter an MPAN that's 13 digits long, like 1234567891011")

    fill_in "Add an MPAN", with: "testing text"

    click_button "Save and continue"

    expect(page).to have_text("Enter an MPAN that's 13 digits long, like 1234567891011")

    fill_in "Add an MPAN", with: "1234567890123"

    click_button "Save and continue"

    expect(page).not_to have_text("Enter an MPAN that's 13 digits long, like 1234567891011")

    choose "Yes"

    click_button "Save and continue"

    expect(page).to have_text("Enter the supply capacity")

    expect(page).to have_text("Enter the data aggregator")

    expect(page).to have_text("Enter the data collector")

    expect(page).to have_text("Enter the meter operator")

    fill_in "What is the supply capacity, in kilovolt-amperes (kVA)?", with: "1000"

    click_button "Save and continue"

    expect(page).not_to have_text("Enter the supply capacity")

    fill_in "Who is the data aggregator?", with: "123"

    click_button "Save and continue"

    expect(page).to have_text("Enter the name of your data aggregator")

    fill_in "Who is the data aggregator?", with: "Test Aggregator"

    click_button "Save and continue"

    expect(page).not_to have_text("Enter the name of your data aggregator")

    fill_in "Who is the data collector?", with: "123"

    click_button "Save and continue"

    expect(page).to have_text("Enter the name of your data collector")

    fill_in "Who is the data collector?", with: "Test Collector"

    click_button "Save and continue"

    expect(page).not_to have_text("Enter the name of your data collector")

    fill_in "Who is the meter operator?", with: "123"

    click_button "Save and continue"

    expect(page).to have_text("Enter the name of your meter operator")

    fill_in "Who is the meter operator?", with: "Test Operator"

    click_button "Save and continue"

    expect(page).not_to have_text("Enter the name of your meter operator")

    fill_in "Estimated annual electricity usage, in kilowatt hours (kWh)", with: "text"

    click_button "Save and continue"

    expect(page).to have_text("Estimated annual usage in kilowatt hours must be a number between 1 and 1,000,000. For example, 93,800")

    fill_in "Estimated annual electricity usage, in kilowatt hours (kWh)", with: "1000"

    click_button "Save and continue"

    expect(page).not_to have_text("Estimated annual usage in kilowatt hours must be a number between 1 and 1,000,000. For example, 93,800")

    visit new_energy_case_org_electricity_meter_path(onboarding_case, case_organisation)

    fill_in "Add an MPAN", with: "1234567890123"

    click_button "Save and continue"

    expect(page).to have_text("This MPAN is already registered with Energy for Schools. Contact dfe-energy.services-team@education.gov.uk to resolve the matter")

    fill_in "Add an MPAN", with: "1234567890124"

    click_button "Save and continue"

    expect(page).not_to have_text("This MPAN is already registered with Energy for Schools. Contact dfe-energy.services-team@education.gov.uk to resolve the matter")

    visit new_energy_case_org_electricity_meter_path(onboarding_case, case_organisation)

    fill_in "Add an MPAN", with: "1234567890555"

    click_button "Save and continue"

    expect(page).to have_text("This MPAN is already registered with Energy for Schools. Contact dfe-energy.services-team@education.gov.uk to resolve the matter")

    another_support_case.update!(state: :closed)

    click_button "Save and continue"

    expect(page).not_to have_text("This MPAN is already registered with Energy for Schools. Contact dfe-energy.services-team@education.gov.uk to resolve the matter")

    create(:energy_electricity_meter, :with_valid_data, mpan: "1234512345121", energy_onboarding_case_organisation_id: case_organisation.id)

    create(:energy_electricity_meter, :with_valid_data, mpan: "1234512345122", energy_onboarding_case_organisation_id: case_organisation.id)

    create(:energy_electricity_meter, :with_valid_data, mpan: "1234512345123", energy_onboarding_case_organisation_id: case_organisation.id)

    visit energy_case_org_electricity_meter_index_path(onboarding_case, case_organisation)

    # Find the table body
    table_body = find(".govuk-table__body")

    # Extract the MPAN values from the table rows
    mpan_values = table_body.all("tr").map do |row|
      row.find("td", match: :first).text.strip # MPAN is in the first column
    end

    # Check the order of the MPAN values
    expected_order = %w[1234567890123 1234512345121 1234512345122 1234512345123]
    expect(mpan_values).to eq(expected_order)

    visit new_energy_case_org_electricity_meter_path(onboarding_case, case_organisation)

    fill_in "Add an MPAN", with: "(123) 45123-45555"

    choose "No"

    fill_in "Estimated annual electricity usage", with: "1000"

    click_button "Save and continue"

    expect(page).not_to have_text("The MPAN must be in the correct format and 13 numbers long")

    expect(page).to have_text("1234512345555")
  end

  specify "Check mpan label" do
    case_organisation.update!(electricity_meter_type: "single")
    visit new_energy_case_org_electricity_meter_path(onboarding_case, case_organisation)
    expect(page).to have_text("Add the MPAN")

    case_organisation.update!(electricity_meter_type: "multi")
    visit new_energy_case_org_electricity_meter_path(onboarding_case, case_organisation)
    expect(page).to have_text("Add an MPAN")
  end
end
