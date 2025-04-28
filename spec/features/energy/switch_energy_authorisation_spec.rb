require "rails_helper"

describe "Switch energy authorisation", :js do
  let(:user) { create(:user) }

  specify "Are you authorised to switch energy suppliers" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    visit energy_school_selection_path

    choose "Supported School Name"

    click_button "Continue"

    expect(page).not_to have_text("Are you authorised to switch energy suppliers for these schools?")
  end
end
