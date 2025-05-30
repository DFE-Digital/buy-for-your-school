require "rails_helper"

describe "Billing preferences", :js do
  let(:support_organisation) { create(:support_organisation, urn: 100_253) }
  let(:user) { create(:user, :many_supported_schools_and_groups) }
  let(:support_case) { create(:support_case, organisation: support_organisation) }
  let(:onboarding_case) { create(:onboarding_case, support_case:) }
  let(:case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case:, onboardable: support_organisation) }

  specify "Specifying billing preferences" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    visit energy_case_org_billing_preferences_path(onboarding_case, case_organisation)

    expect(page).to have_text("Billing preferences")
    expect(page).to have_link("Discard and go to task list", href: energy_case_tasks_path(case_id: onboarding_case.id))

    click_button "Save and continue"
    expect(page).to have_text("Select your preferred method of payment")

    choose "BACS"
    click_button "Save and continue"
    expect(page).to have_text("Select your payment terms")

    choose "14 days"
    click_button "Save and continue"
    expect(page).to have_text("Select how you'd like to be invoiced")

    choose "Email"
    click_button "Save and continue"
    expect(page).to have_text("Enter an email address in the correct format, like name@example.com")

    fill_in "Email address", with: "foo@bar.com"
    click_button "Save and continue"
    expect(page).not_to have_text("There is a problem")
  end
end
