require "rails_helper"

describe "User can update the electricity cosolidation", :js do
  include_context "with energy suppliers"

  specify "MPANs consolidated on one bill" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)
    case_organisation.update!(is_electric_bill_consolidated: nil)

    visit energy_case_org_electric_bill_consolidation_path(case_id: case_organisation.energy_onboarding_case_id, org_id: case_organisation.onboardable_id)

    expect(page).to have_text("Electricity meters and usage")
    expect(page).to have_text("Do you want your MPANs consolidated on one bill?")
    expect(page).to have_link("Discard and go to task list", href: energy_case_tasks_path(case_id: onboarding_case.id))

    click_button "Save and continue"
    expect(page).to have_text("Please select one option to proceed")

    choose "Yes"
    click_button "Save and continue"
    expect(page).not_to have_text("Please select at least one option to proceed")
  end
end
