require "rails_helper"

describe "School selection", :js do
  let(:user) { create(:user, :many_supported_schools) }

  specify "Authenticating and seeing the school selection" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    create(:support_organisation, urn: 100_253)

    visit energy_school_selection_path

    expect(page).to have_text("Which school are you buying for?")

    expect(page).to have_text("Specialist School for Testing")

    expect(page).not_to have_text("Greendale Academy for Bright Sparks")

    click_button "Continue"

    expect(page).to have_text("Please select at least one option to proceed")

    choose "Specialist School for Testing"

    click_button "Continue"

    expect(page).not_to have_text("Please select at least one option to proceed")
  end
end
