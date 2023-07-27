require "rails_helper"

describe "Visitor to GHBS service sees cookie banner", js: true do
  scenario "Visitor accepting cookie notice can be tracked by GA" do
    Given :"I am a new visitor to the GHBS service"
    When :"I accept the tracking of cookies"
    Then :"I have a cookie to enable tracking with GA"
  end

protected

  def_Given :"I am a new visitor to the GHBS service" do
    visit "/"
  end

  def_When :"I accept the tracking of cookies" do
    click_button "Accept analytics cookies"
  end

  def_Then :"I have a cookie to enable tracking with GA" do
    expect(page).to have_content("You’ve accepted analytics cookies")
  end
end
