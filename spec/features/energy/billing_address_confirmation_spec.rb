require "rails_helper"

describe "Billing address confirmation", :js do
  include_context "with energy suppliers"

  let(:formatted_address) { Support::OrganisationPresenter.new(support_organisation).formatted_address }

  specify "Select an address" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    visit energy_case_org_billing_address_confirmation_path(onboarding_case, case_organisation)

    expect(page).to have_text("Billing address")
    expect(page).to have_link("Discard and go to task list", href: energy_case_tasks_path(case_id: onboarding_case.id))

    click_button "Save and continue"

    expect(page).to have_text("Select a billing address")
    expect(page).to have_link("Discard and go to task list", href: energy_case_tasks_path(case_id: onboarding_case.id))

    choose formatted_address.to_s

    click_button "Save and continue"

    expect(page).not_to have_text("Select a billing address")
  end
end
