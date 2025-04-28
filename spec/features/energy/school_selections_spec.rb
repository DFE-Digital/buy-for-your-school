require "rails_helper"

describe "School selection", :js do
  let(:user) { create(:user) }

  specify "Authenticating and seeing the school selection" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    visit energy_school_selection_path

    expect(page).to have_text("Which school are you buying for?")

    click_button "Continue"

    expect(page).to have_text("Please select at least one option to proceed")

    choose "Supported School Name"

    click_button "Continue"

    expect(page).not_to have_text("Please select at least one option to proceed")
  end
end
