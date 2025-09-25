require "rails_helper"

describe "School selection", :js do
  let(:user) { create(:user, :many_supported_schools_and_groups) }

  specify "Authenticating, seeing the school selection, selecting a trust, selecting a school in the trust" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    create(:support_organisation, urn: 100_253)

    create(:support_establishment_group, uid: 2314,
                                         establishment_group_type: create(:support_establishment_group_type, code: 2))

    create(:support_organisation, name: "St. Trinians", trust_code: 2314)
    create(:support_organisation, name: "Hogwarts", trust_code: 2314)

    visit energy_school_selection_path

    expect(page).to have_text("Which school are you buying for?")

    expect(page).to have_text("Specialist School for Testing")
    click_button "Continue"

    expect(page).to have_text("Select the school you are buying for")

    choose "Testing Multi Academy Trust"
    click_button "Continue"

    expect(page).to have_text("Which school in your academy trust")

    choose "Hogwarts"
    click_button "Continue"

    expect(page).to have_text("Are you authorised to switch energy suppliers for these schools?")
  end
end
