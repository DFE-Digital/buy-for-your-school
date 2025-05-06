require "rails_helper"

describe "User can update gas usage", :js do
  let(:support_organisation) { create(:support_organisation, urn: 100_253) }
  let(:user) { create(:user, :many_supported_schools_and_groups) }
  let(:support_case) { create(:support_case, organisation: support_organisation) }
  let(:onboarding_case) { create(:onboarding_case, support_case:) }
  let(:case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case:, onboardable: support_organisation) }

  specify "MPRNs consolidated on one bill" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    visit energy_case_org_gas_bill_consolidation_path(case_id: case_organisation.energy_onboarding_case_id, org_id: case_organisation.onboardable_id)

    expect(page).to have_text("Gas meters and usage")

    expect(page).to have_text("Do you want your MPRNs consolidated on one bill?")

    click_button "Save and continue"

    expect(page).to have_text("Please select at least one option to proceed")

    choose "Yes"

    click_button "Save and continue"

    expect(page).not_to have_text("Please select at least one option to proceed")
  end
end
