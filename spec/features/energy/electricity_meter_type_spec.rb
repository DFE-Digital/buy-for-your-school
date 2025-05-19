require "rails_helper"

describe "User can update electricity meters and usage", :js do
  include_context "with energy suppliers"

  specify "single or multi meter" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    visit energy_case_org_electricity_meter_type_path(onboarding_case, case_organisation)

    expect(page).to have_text("Electricity meters and usage")

    expect(page).to have_text("Is this a single or multi meter site?")

    click_button "Save and continue"

    expect(page).to have_text("Please select at least one option to proceed")

    choose "Multi meter"

    click_button "Save and continue"

    expect(page).not_to have_text("Please select at least one option to proceed")

    create(:energy_electricity_meter, :with_valid_data, mpan: "1234512345121", energy_onboarding_case_organisation_id: case_organisation.id)

    create(:energy_electricity_meter, :with_valid_data, mpan: "1234512345122", energy_onboarding_case_organisation_id: case_organisation.id)

    create(:energy_electricity_meter, :with_valid_data, mpan: "1234512345123", energy_onboarding_case_organisation_id: case_organisation.id)

    visit energy_case_org_electricity_meter_type_path(onboarding_case, case_organisation)

    choose "Single meter"

    click_button "Save and continue"

    expect(case_organisation.electricity_meters.count).to be(1)

    expect(case_organisation.electricity_meters.last.mpan).to eq("1234512345121")
  end
end
