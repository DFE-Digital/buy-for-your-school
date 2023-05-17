require "rails_helper"

describe "Admin can set Support Agents as Internal or Proc-Ops" do
  include_context "with an agent", roles: %w[global_admin]

  let!(:support_agent) { create(:support_agent, first_name: "Test", last_name: "User") }

  scenario "Admin sets agent as Proc-ops" do
    visit support_management_agents_path
    within "tr", text: "Test User" do
      click_on "Edit"
    end
    check "Procurement Operations Staff Member"
    click_on "Save"

    expect(support_agent.reload.roles).to include("procops")
  end
end
