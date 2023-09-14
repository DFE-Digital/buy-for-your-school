require "rails_helper"

describe "Agent can create providers", js: true do
  include_context "with a framework evaluation agent"

  it "creates and takes you to the new framework provider" do
    visit frameworks_root_path
    click_on "Providers"
    click_on "Add Provider"
    fill_in "Name", with: "New Provider 1"
    fill_in "Short name", with: "NP1"
    click_on "Create provider"

    expect(page).to have_css(".govuk-heading-l", text: "New Provider 1")
    expect(page).to have_summary("Short name", "NP1")
  end
end
