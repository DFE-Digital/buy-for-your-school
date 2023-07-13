require "rails_helper"

describe "Admin can create an Agent" do
  include_context "with an agent", roles: %w[global_admin]

  scenario "Admin creates a new agent and sets roles" do
    visit support_management_agents_path

    click_on "New Agent"
    fill_in "First name", with: "Abbey"
    fill_in "Last name", with: "Dale"
    fill_in "Email", with: "abbeydale@education.gov.uk"
    check "Procurement Operations Staff Member"
    click_on "Save"

    within "tr", text: "Abbey Dale" do
      expect(page).to have_content("Procurement Operations Staff Member")
    end
  end
end
