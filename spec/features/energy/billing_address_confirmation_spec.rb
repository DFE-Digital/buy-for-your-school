require "rails_helper"

describe "Billing address confirmation", :js do
  include_context "with energy suppliers"

  let(:formatted_address) { Support::OrganisationPresenter.new(support_organisation).formatted_address }

  before do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)
  end

  specify "Select an address" do
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

  describe "Billing address selection for school belongs to trust" do
    let(:support_organisation) { create(:support_organisation, :with_address, urn: 100_253, trust_code: "2001") }
    let(:support_establishment_group) { create(:support_establishment_group, :with_address, uid: support_organisation.trust_code) }

    before do
      support_establishment_group
    end

    specify "select an address" do
      visit energy_case_org_billing_address_confirmation_path(onboarding_case, case_organisation)

      expect(page).to have_text("Billing address")

      expect(page).to have_field(support_organisation.name, type: "radio")
      expect(page).to have_field(support_establishment_group.name, type: "radio")

      first(:radio_button).choose

      click_button "Save and continue"
      expect(page).not_to have_text("Billing address")
    end
  end
end
