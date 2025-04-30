require "rails_helper"

describe "Current Gas supplier", :js do
  let(:user) { create(:user) }

  specify "Authenticating and seeing the current gas supplier" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    visit energy_mat_gas_contract_path

    expect(page).to have_text("About your schools: Current contract details")
    expect(page).to have_text("Current gas supplier")

    click_button "Save and continue"

    expect(page).to have_text("There is a problem")
    expect(page).to have_text("Please fill in all fields")

    choose "Scotish Power"

    fill_in "contract-end-day", with: "30"
    fill_in "contract-end-month", with: "11"
    fill_in "contract-end-year", with: "2025"

    # todo: add more tests
    # click_button "Save and continue"
  end
end
