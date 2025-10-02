RSpec.shared_context "with current energy contract" do |energy_type|
  let(:support_organisation) { create(:support_organisation, urn: 100_253) }
  let(:user) { create(:user, :many_supported_schools_and_groups) }
  let(:support_case) { create(:support_case, organisation: support_organisation) }
  let(:onboarding_case) { create(:onboarding_case, support_case:) }
  let(:case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case:, onboardable: support_organisation) }

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
    fill_in "Day", with: "11"
    fill_in "Month", with: "11"
    fill_in "Year", with: "2028"

    click_button "Save and continue"
    expect(page).to have_text(energy_type_error)

    fill_in_supplier_and_contract_end_date(day: "31", month: "12", year: "2035") # check upper limit of date
    expect(page).to have_text("Enter a contract end date that’s no more than 1 year prior to and no more than 5 years from today’s date")

    fill_in_supplier_and_contract_end_date(day: "10", month: "05", year: "2024") # check lower limit of date
    expect(page).to have_text("Enter a contract end date that’s no more than 1 year prior to and no more than 5 years from today’s date")

    fill_in_supplier_and_contract_end_date(day: "32", month: "01", year: "2025") # check invalid date
    expect(page).to have_text("Enter a valid date")

    fill_in_supplier_and_contract_end_date(day: "29", month: "02", year: "2025") # check non leap year
    expect(page).to have_text("Enter a valid date")

    fill_in_supplier_and_contract_end_date(day: "31", month: "12", year: "2025")
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
