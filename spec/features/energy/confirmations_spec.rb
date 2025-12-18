require "rails_helper"

describe "School selection", :js do
  include_context "with energy suppliers"

  before do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)
  end

  specify "Information submitted screen" do
    visit energy_case_confirmation_path(case_id: case_organisation.energy_onboarding_case_id)
    expect(page).to have_text("Information submitted")
    expect(page).to have_text("Depending on your contract's end date, you may be placed on an interim rate to ensure continued supply to your school.")
    expect(page).to have_text("Check your current contract's termination terms and notice period to find out how much notice you need to provide to switch suppliers. You must provide notice to your current supplier in writing. DfE cannot do this for you.")
  end

  context "when allow_mat_flow feature flag is OFF" do
    before do
      Flipper.disable(:allow_mat_flow)
      visit energy_case_confirmation_path(case_id: case_organisation.energy_onboarding_case_id)
    end

    it "shows Information submitted screen for single school" do
      expect(page).to have_text("We've sent an email to #{onboarding_case.support_case&.email} containing a copy of this form and details about your new contract.")
      click_link "What did you think of this service?"
      expect(page).to have_text("Get help buying for schools feedback")
      expect(page).to have_text("Thank you for taking the time to give us your feedback.")
    end
  end

  context "when allow_mat_flow feature flag is ON" do
    let(:support_establishment_group) { create(:support_establishment_group, uid: 2314, establishment_group_type: create(:support_establishment_group_type, code: 2)) }
    let(:support_organisation) { create(:support_organisation, trust_code: 2314) }
    let(:support_organisation_2) { create(:support_organisation, trust_code: 2314) }
    let(:user) { create(:user, :many_supported_schools_and_groups) }
    let(:support_case) { create(:support_case, organisation: support_organisation) }
    let(:onboarding_case) { create(:onboarding_case, support_case:) }
    let(:case_organisation) { create(:energy_onboarding_case_organisation, :with_energy_details, onboarding_case:, onboardable: support_organisation) }

    before do
      Flipper.enable(:allow_mat_flow)
      visit energy_case_confirmation_path(case_id: case_organisation.energy_onboarding_case_id)
    end

    it "shows Information submitted screen for mat schools" do
      expect(page).to have_text("We've sent a confirmation email to #{onboarding_case.support_case&.email} containing a copy of this form and information about what happens next.")
      expect(page).to have_text("Use this service again to switch another school to the energy contract if you're a multi-academy trust.")
      expect(page).to have_link("Switch another school")
      expect(page).to have_text("Alternatively, fill in the Register your interest form and complete the paperwork for any additional schools offline.")
    end
  end
end
