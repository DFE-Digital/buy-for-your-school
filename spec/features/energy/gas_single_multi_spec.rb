require "rails_helper"

describe "Gas single or multi-meter selection", :js do
  include_context "with energy suppliers"
  specify "Selecting single or multi" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    visit energy_case_org_gas_single_multi_path(onboarding_case, case_organisation)

    expect(page).to have_text("Is this a single or multi meter site?")
    expect(page).to have_link("Discard and go to task list", href: energy_case_tasks_path(case_id: onboarding_case.id))

    click_button "Save and continue"

    expect(page).to have_text("Select whether your school is single or multi meter")

    find('input[type="radio"][value="multi"]', match: :first).click

    click_button "Save and continue"

    expect(page).not_to have_text("Select whether your school is single or multi meter")

    create(:energy_gas_meter, :with_valid_data, mprn: "12345666", energy_onboarding_case_organisation_id: case_organisation.id)

    create(:energy_gas_meter, :with_valid_data, mprn: "12345777", energy_onboarding_case_organisation_id: case_organisation.id)

    create(:energy_gas_meter, :with_valid_data, mprn: "12345887", energy_onboarding_case_organisation_id: case_organisation.id)

    visit energy_case_org_gas_single_multi_path(onboarding_case, case_organisation)

    expect(case_organisation.gas_meters.count).to be(3)

    choose "Single meter"

    click_button "Save and continue"

    expect(case_organisation.gas_meters.count).to be(0)

    create(:energy_gas_meter, :with_valid_data, mprn: "12345888", energy_onboarding_case_organisation_id: case_organisation.id)

    visit energy_case_org_gas_single_multi_path(onboarding_case, case_organisation)

    expect(case_organisation.gas_meters.count).to be(1)

    choose "Multi meter"

    click_button "Save and continue"

    expect(case_organisation.gas_meters.count).to be(0)
  end
end
