require "rails_helper"

describe "User can update gas usage details", :js do
  include_context "with energy suppliers"
  specify "Adding gas usage" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    case_organisation.update!(gas_single_multi: "multi")

    case_organisation.reload

    visit new_energy_case_org_gas_meter_path(onboarding_case, case_organisation)

    expect(page).to have_text("Gas meter details")
    expect(page).to have_link("Discard and go to task list", href: energy_case_tasks_path(case_id: onboarding_case.id))

    click_button "Save and continue"

    expect(page).to have_text("Enter a Meter Point Reference Number")

    expect(page).to have_text("Enter the estimated annual usage in kilowatt hours")

    fill_in "Add a Meter Point Reference Number (MPRN)", with: "10"

    click_button "Save and continue"

    expect(page).to have_text("Enter an MPRN between 6 and 12 digits, like 12345678")

    fill_in "Add a Meter Point Reference Number (MPRN)", with: "testing text"

    click_button "Save and continue"

    expect(page).to have_text("Enter an MPRN between 6 and 12 digits, like 12345678")

    fill_in "Add a Meter Point Reference Number (MPRN)", with: "3938424403"

    click_button "Save and continue"

    expect(page).not_to have_text("Enter an MPRN between 6 and 12 digits, like 12345678")

    fill_in "Estimated annual gas usage for this meter, in kilowatt hours", with: "text"

    click_button "Save and continue"

    expect(page).to have_text("Estimated annual usage in kilowatt hours must be a number between 1 and 1,000,000. For example, 93,800")

    fill_in "Estimated annual gas usage for this meter, in kilowatt hours", with: "1000"

    click_button "Save and continue"

    expect(page).not_to have_text("Estimated annual usage in kilowatt hours must be a number between 1 and 1,000,000. For example, 93,800")

    visit new_energy_case_org_gas_meter_path(onboarding_case, case_organisation)

    fill_in "Add a Meter Point Reference Number (MPRN)", with: "3938424403"

    click_button "Save and continue"

    expect(page).to have_text("This MPRN is already registered with Energy for Schools. Contact dfe-energy.services-team@education.gov.uk to resolve the matter")

    fill_in "Add a Meter Point Reference Number (MPRN)", with: "3938424404"

    click_button "Save and continue"

    expect(page).not_to have_text("This MPRN is already registered with Energy for Schools. Contact dfe-energy.services-team@education.gov.uk to resolve the matter")

    create(:energy_gas_meter, :with_valid_data, mprn: "12345666", energy_onboarding_case_organisation_id: case_organisation.id)

    create(:energy_gas_meter, :with_valid_data, mprn: "12345777", energy_onboarding_case_organisation_id: case_organisation.id)

    create(:energy_gas_meter, :with_valid_data, mprn: "12345888", energy_onboarding_case_organisation_id: case_organisation.id)

    visit energy_case_org_gas_meter_index_path(onboarding_case, case_organisation)

    # Find the table body
    table_body = find(".govuk-table__body")

    # Extract the MPRN values from the table rows
    mprn_values = table_body.all("tr").map do |row|
      row.find("td", match: :first).text.strip # MPRN is in the first column
    end

    # Check the order of the MPRN values
    expected_order = %w[3938424403 12345666 12345777 12345888]
    expect(mprn_values).to eq(expected_order)

    visit new_energy_case_org_gas_meter_path(onboarding_case, case_organisation)

    fill_in "Add a Meter Point Reference Number (MPRN)", with: "(393) 842-4999"

    fill_in "Estimated annual gas usage for this meter, in kilowatt hours", with: "1000"

    click_button "Save and continue"

    expect(page).not_to have_text("The MPRN must be in the correct format and between 6 and 12 numbers long")

    expect(page).to have_text("3938424999")

    visit energy_case_org_gas_single_multi_path(onboarding_case, case_organisation)

    choose "Single meter"

    click_button "Save and continue"

    expect(page).to have_text("Add the Meter Point Reference Number (MPRN)")
  end
end
