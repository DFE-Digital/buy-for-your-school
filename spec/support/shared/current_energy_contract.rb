RSpec.shared_context "with current energy contract" do |energy_type|
  let(:support_organisation) { create(:support_organisation, urn: 100_253) }
  let(:user) { create(:user, :many_supported_schools_and_groups) }
  let(:support_case) { create(:support_case, organisation: support_organisation) }
  let(:onboarding_case) { create(:onboarding_case, support_case:) }
  let(:case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case:, onboardable: support_organisation) }

  let(:too_far_future_year) { 6.years.from_now.year }
  let(:too_far_past_year) { 6.years.ago.year }
  let(:current_year) { Time.zone.today.year }

  let(:expected_suppliers) do
    [
      "British Gas",
      "EDF Energy",
      "E.ON Next",
      "Scottish Power",
      "OVO Energy",
      "Octopus Energy",
      "Other",
    ]
  end

  specify "Authenticating and seeing the current electric supplier" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    path = if energy_type == "electric"
             energy_case_electric_supplier_path(case_id: case_organisation.energy_onboarding_case_id)
           else
             energy_case_gas_supplier_path(case_id: case_organisation.energy_onboarding_case_id)
           end

    energy_type_error = if energy_type == "electric"
                          "Select an electricity supplier"
                        else
                          "Select a gas supplier"
                        end

    visit path

    expect(page).to have_text("#{support_organisation.name}: Current ")
    expected_suppliers.each do |supplier|
      expect(page).to have_text(supplier)
    end
    expect(page).to have_text("When does the contract end?")
    expect(page).to have_link("Discard and go to task list", href: energy_case_tasks_path(case_id: onboarding_case.id))

    click_button "Save and continue"
    expect(page).to have_text(energy_type_error)
    expect(page).to have_text("Enter a contract end date") # missing date

    fill_in_supplier_and_contract_end_date(day: "31", month: "12", year: too_far_future_year) # check upper limit of date
    expect(page).to have_text("Enter a contract end date that’s no more than 1 year prior to and no more than 5 years from today’s date")

    fill_in_supplier_and_contract_end_date(day: "10", month: "05", year: too_far_past_year) # check lower limit of date
    expect(page).to have_text("Enter a contract end date that’s no more than 1 year prior to and no more than 5 years from today’s date")

    fill_in_supplier_and_contract_end_date(day: "32", month: "01", year: current_year) # check invalid date
    expect(page).to have_text("Contract end date must be a real date")

    fill_in_supplier_and_contract_end_date(day: "29", month: "02", year: current_year) # check non leap year
    expect(page).to have_text("Contract end date must be a real date")

    fill_in_supplier_and_contract_end_date(day: "29", month: "", year: current_year) # enter date with month missing
    expect(page).to have_text("Enter a month")

    fill_in_supplier_and_contract_end_date(day: "", month: "3", year: current_year) # enter date with day missing
    expect(page).to have_text("Enter a day")

    fill_in_supplier_and_contract_end_date(day: "29", month: "4", year: "") # enter date with year missing
    expect(page).to have_text("Enter a year")

    fill_in_supplier_and_contract_end_date(day: "29", month: "", year: "") # enter date with month and year missing
    expect(page).to have_text("Enter a year")
    expect(page).to have_text("Enter a month")

    fill_in_supplier_and_contract_end_date(day: "31", month: "12", year: current_year)
    expect(page).not_to have_current_path(path)
  end

  def fill_in_supplier_and_contract_end_date(day:, month:, year:)
    find('input[type="radio"][value="british_gas"]', match: :first).click
    fill_in "Day", with: day
    fill_in "Month", with: month
    fill_in "Year", with: year
    click_button "Save and continue"
  end
end
