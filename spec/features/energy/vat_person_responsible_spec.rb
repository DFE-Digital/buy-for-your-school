require "rails_helper"

describe "VAT person responsible", :js do
  let(:support_organisation) { create(:support_organisation, urn: 100_253) }
  let(:user) { create(:user, :many_supported_schools_and_groups) }
  let(:support_case) { create(:support_case, organisation: support_organisation) }
  let(:onboarding_case) { create(:onboarding_case, support_case:) }
  let(:case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case:, onboardable: support_organisation) }

  specify "Specifying if correct details" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    visit energy_case_org_vat_person_responsible_path(onboarding_case, case_organisation)

    expect(page).to have_text("Are these the correct details for VAT purposes?")

    click_button "Save and continue"

    expect(page).to have_text("Select whether these are the correct details")

    choose "Yes"

    click_button "Save and continue"

    expect(page).not_to have_text("Select whether these are the correct details")
  end
end
