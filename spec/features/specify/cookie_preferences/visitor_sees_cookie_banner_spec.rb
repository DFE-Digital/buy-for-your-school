require "rails_helper"

describe "Visitor to GHBS service sees cookie banner", :js do
  before { Flipper.enable(:ghbs_public_frontend) }

  scenario "Visitor accepting cookie notice can be tracked by GA" do
    Given :"I am a new visitor to the GHBS service"
    When :"I accept the tracking of cookies"
    Then :"I have a cookie to enable tracking with GA"
  end

  scenario "Visitor to the contentful homepage accepting cookie notice can be tracked by GA" do
    Given :"I am a new visitor to the GHBS service on the contentful homepage"
    When :"I accept the tracking of cookies"
    Then :"I have a cookie to enable tracking with GA"
  end

protected

  def_Given :"I am a new visitor to the GHBS service" do
    visit "/cms"
  end

  def_Given :"I am a new visitor to the GHBS service on the contentful homepage" do
    visit "/"
  end

  def_When :"I accept the tracking of cookies" do
    click_button "Accept analytics cookies"
  end

  def_Then :"I have a cookie to enable tracking with GA" do
    expect(page).to have_content("You’ve accepted analytics cookies")
  end
end
