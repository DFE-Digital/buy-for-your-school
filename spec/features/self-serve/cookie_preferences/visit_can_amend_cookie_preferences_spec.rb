require "rails_helper"

describe "Visitor can amend cookie preferences" do
  scenario "Visitor updates cookie preferences" do
    Given :"I am a visitor wanting to update my cookie preferences"
    When :"I update my cookie preferences"
    Then :"I am notified my changes have been saved"
  end

protected

  def_Given :"I am a visitor wanting to update my cookie preferences" do
    visit cookie_preferences_path
  end

  def_When :"I update my cookie preferences" do
    choose "Yes"
    click_button "Save cookie settings"
  end

  def_Then :"I am notified my changes have been saved" do
    expect(page).to have_content("Your cookie settings were saved")
  end
end
