require "rails_helper"

describe "Admin can set Support Agents as Internal or Proc-Ops" do
  include_context "with an agent"
  let!(:support_agent) { create(:support_agent, first_name: "Test", last_name: "User", internal: true) }

  scenario "Admin sets agent as Proc-ops (not internal)" do
    Given :"I am an admin"
    When :"I set the support agent user type to proc-ops"
    Then :"the agent is now set as proc-ops"
  end

protected

  def_Given :"I am an admin" do
    user.update!(roles: %w[admin])
  end

  def_When :"I set the support agent user type to proc-ops" do
    click_button "Agent Login"
    visit support_management_agents_path

    within "tr", text: "Test User" do
      choose "Proc-Ops"
      click_on "Save"
    end
  end

  def_Then :"the agent is now set as proc-ops" do
    expect(support_agent.reload.internal).to be(false)
  end
end
