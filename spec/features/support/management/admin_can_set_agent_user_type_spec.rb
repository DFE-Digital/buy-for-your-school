require "rails_helper"

describe "Admin can set Support Agents as Internal or Proc-Ops" do
  include_context "with an agent", roles: %w[global_admin]

  let!(:support_agent) { create(:support_agent, first_name: "Test", last_name: "User", email: "test.user@test.com") }

  scenario "Admin sets agent as Proc-ops" do
    visit support_management_agents_path
    within "tr", text: "Test User" do
      click_on "Edit"
    end
    check "Procurement Operations Staff Member"
    click_on "Save"

    expect(support_agent.reload.roles).to include("procops")
  end

  scenario "Admin can delete agent" do
    visit support_management_agents_path
    within "tr", text: "Test User" do
      click_on "Remove"
    end
    expect(page).to have_text("Are you sure you want to remove Test User (test.user@test.com)?")

    click_on "Remove"

    expect(page).to have_text("Test User (test.user@test.com) successfully removed")

    expect(support_agent.reload.archived).to be(true)

    click_on "New Agent"

    fill_in "First name", with: "Test"
    fill_in "Last name", with: "User"
    fill_in "Email", with: "test.user@test.com"
    check "Procurement Operations Staff Member"

    click_on "Save"

    expect(support_agent.reload.archived).to be(false)
  end
end
