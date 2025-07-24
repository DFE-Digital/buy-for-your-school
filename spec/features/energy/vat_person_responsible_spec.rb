require "rails_helper"

describe "VAT person responsible", :js do
  let(:support_organisation) { create(:support_organisation, urn: 100_253) }
  let(:user) { create(:user, :many_supported_schools_and_groups) }
  let(:support_case) { create(:support_case, organisation: support_organisation) }
  let(:onboarding_case) { create(:onboarding_case, support_case:) }
  let(:case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case:, onboardable: support_organisation) }

  before do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)
    visit energy_case_org_vat_person_responsible_path(onboarding_case, case_organisation)
  end

  specify "Specifying if correct details and choosing Yes" do
    expect(page).to have_text("Are these the correct details for VAT purposes?")
    expect(page).to have_link("Discard and go to task list", href: energy_case_tasks_path(case_id: onboarding_case.id))

    click_button "Save and continue"
    expect(page).to have_text("Select yes if these are the correct details for VAT purposes")

    choose "Yes"
    click_button "Save and continue"
    expect(page).not_to have_text("Select yes if these are the correct details for VAT purposes")
  end

  specify "Specifying if correct details and choosing No" do
    choose "No"
    click_button "Save and continue"
    expect(page).to have_text("VAT contact information")
    expect(page).not_to have_text("Select yes if these are the correct details for VAT purposes")
  end
end
