require "rails_helper"

describe "User can update energy type", :js do
  let(:user) { create(:user) }

  specify "Verify the single school fuel selection" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    visit energy_switch_energy_path

    expect(page).to have_text("Are you switching electricity, gas or both?")

    click_button "Continue"

    expect(page).to have_text("There is a problem")

    expect(page).to have_text("Please select at least one option to proceed")
  end
end
