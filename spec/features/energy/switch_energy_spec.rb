require "rails_helper"

describe "User can update energy type", :js do
  include_context "with energy suppliers"
  specify "Verify the single school fuel selection" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    visit energy_case_switch_energy_path(onboarding_case, case_organisation)

    expect(page).to have_text("Are you switching electricity, gas or both?")
    expect(page).to have_text("Electricity only")
    expect(page).to have_text("Gas only")
    expect(page).to have_text("Gas and electricity")
    expect(page).not_to have_link("Discard and go to task list", href: energy_case_tasks_path(case_id: onboarding_case.id))

    choose "Gas and electricity"

    click_button "Save and continue"

    create(:energy_gas_meter, :with_valid_data, energy_onboarding_case_organisation_id: case_organisation.id)

    expect(case_organisation.gas_meters.any?).to be(true)

    visit energy_case_switch_energy_path(onboarding_case, case_organisation)

    choose "Electricity only"

    click_button "Save and continue"

    expect(case_organisation.gas_meters.any?).to be(false)

    create(:energy_electricity_meter, :with_valid_data, energy_onboarding_case_organisation_id: case_organisation.id)

    expect(case_organisation.electricity_meters.any?).to be(true)

    visit energy_case_switch_energy_path(onboarding_case, case_organisation)

    choose "Gas only"

    click_button "Save and continue"

    visit energy_case_switch_energy_path(onboarding_case, case_organisation)

    expect(case_organisation.electricity_meters.any?).to be(false)
  end
end
