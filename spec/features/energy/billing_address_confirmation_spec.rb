require "rails_helper"

describe "Billing address confirmation", :js do
  let(:support_organisation) { create(:support_organisation, urn: 100_253) }
  let(:user) { create(:user, :many_supported_schools_and_groups) }
  let(:support_case) { create(:support_case, organisation: support_organisation) }
  let(:onboarding_case) { create(:onboarding_case, support_case:) }
  let(:case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case:, onboardable: support_organisation) }
  let(:formatted_address) { Support::OrganisationPresenter.new(support_organisation).formatted_address }

  specify "Select an address" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    visit energy_case_org_billing_address_confirmation_path(onboarding_case, case_organisation)

    expect(page).to have_text("Billing address")

    click_button "Save and continue"

    expect(page).to have_text("Select a billing address")

    choose formatted_address.to_s

    click_button "Save and continue"

    expect(page).not_to have_text("Select a billing address")
  end
end
