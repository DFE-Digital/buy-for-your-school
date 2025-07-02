require "rails_helper"

describe "Multi case for school", :js do
  include_context "with energy suppliers"

  before do
    case_organisation
    Current.user = user
    Current.user.email = support_case.email
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)
  end

  context "with an already submitted case for the school" do
    before do
      onboarding_case.update!(submitted_at: Time.zone.now)
    end

    context "when user selects school from school selection screen" do
      before do
        visit energy_school_selection_path
        choose "Specialist School for Testing"
        click_button "Continue"
      end

      it "allows another case to be created" do
        expect(page).to have_content("Are you authorised to switch energy suppliers for these schools?")
      end
    end

    context "when user follows a saved link into the flow with the case ID" do
      before do
        visit energy_case_switch_energy_path(onboarding_case)
      end

      it "redirects to the submitted page for the case" do
        expect(page).to have_text("Information submitted")
      end
    end
  end
end
