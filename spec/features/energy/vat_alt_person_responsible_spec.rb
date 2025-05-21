require "rails_helper"

describe "VAT Alt person responsible", :js do
  let(:support_organisation) { create(:support_organisation, urn: 100_253) }
  let(:user) { create(:user, :many_supported_schools_and_groups) }
  let(:support_case) { create(:support_case, organisation: support_organisation) }
  let(:onboarding_case) { create(:onboarding_case, support_case:) }
  let(:case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case:, onboardable: support_organisation) }

  before do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)
  end

  specify "Specifying Alternate VAT contact information for school without an Establishment group" do
    visit energy_case_org_vat_alt_person_responsible_path(case_id: case_organisation.energy_onboarding_case_id, org_id: case_organisation.onboardable_id)
    expect(page).to have_text("VAT contact information")

    click_button "Save and continue"
    expect(page).to have_text("Enter a contact name")
    expect(page).to have_text("Enter a phone number")

    fill_in "First name", with: "Jon"
    fill_in "Last name", with: SecureRandom.hex(61)
    fill_in "Telephone number", with: "1234"
    click_button "Save and continue"
    expect(page).not_to have_text("Enter a contact name")
    expect(page).to have_text("Last name must be 60 characters or fewer")
    expect(page).to have_text("Enter a phone number in the correct format, like 01632 960 001")

    fill_in "First name", with: "Jon"
    fill_in "Telephone number", with: "01632 960 001"
    click_button "Save and continue"
    expect(page).not_to have_text("Enter a contact name")
    expect(page).not_to have_text("Enter a phone number in the correct format, like 01632 960 001")
  end

  describe "Establishment group" do
    let(:support_organisation) { create(:support_organisation, :with_address, urn: 100_253, trust_code: "2001") }
    let(:support_establishment_group) { create(:support_establishment_group, :with_address, uid: support_organisation.trust_code) }

    before do
      support_establishment_group
    end

    specify "Specifying Alternate VAT contact information for school with an Establishment group" do
      visit energy_case_org_vat_alt_person_responsible_path(case_id: case_organisation.energy_onboarding_case_id, org_id: case_organisation.onboardable_id)
      expect(page).to have_text("VAT contact information")

      click_button "Save and continue"
      expect(page).to have_text("Enter a contact name")
      expect(page).to have_text("Enter a phone number")
      expect(page).to have_text("Select an address")

      fill_in "First name", with: "Jon"
      fill_in "Telephone number", with: "01632 960 001"
      first(:radio_button).choose

      click_button "Save and continue"
      expect(page).not_to have_text("Select an address")
    end
  end
end
