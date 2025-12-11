require "rails_helper"

describe "School selection", :js do
  let(:user) { create(:user, :many_supported_schools_and_groups) }

  before do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    create(:support_organisation, urn: 100_253)
    create(:support_establishment_group, uid: 2314, establishment_group_type: create(:support_establishment_group_type, code: 2))
    create(:support_organisation, name: "St. Trinians", trust_code: 2314)
    create(:support_organisation, name: "Hogwarts", trust_code: 2314)
  end

  def start_flow
    visit energy_school_selection_path

    expect(page).to have_text("Which school are you buying for?")
    expect(page).to have_text("Specialist School for Testing")
    click_button "Continue"

    expect(page).to have_text("Select the school you are buying for")
    choose "Testing Multi Academy Trust"
    click_button "Continue"
  end

  context "when allow_mat_flow feature flag is ON" do
    before { Flipper.enable(:allow_mat_flow) }

    it "authenticates and completes MAT flow" do
      start_flow

      expect(page).to have_text("Which school in your academy trust")
      choose "Hogwarts"
      click_button "Continue"

      expect(page).to have_text("Are you authorised to switch energy suppliers for these schools?")
    end
  end

  context "when allow_mat_flow feature flag is OFF" do
    before { Flipper.disable(:allow_mat_flow) }

    it "shows single school only message" do
      start_flow

      expect(page).to have_text("Service only available for individual schools")
    end
  end
end
