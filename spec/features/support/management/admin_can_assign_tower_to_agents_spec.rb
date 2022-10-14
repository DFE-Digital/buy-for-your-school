require "rails_helper"

describe "Admin can assign Support Agents to a Tower" do
  include_context "with an agent"
  let!(:ict_tower) { create(:support_tower, title: "ICT") }
  let!(:support_agent) { create(:support_agent, first_name: "Test", last_name: "User") }

  scenario "Admin assigns tower to Agent" do
    Given :"I am an admin"
    When :"I assign a tower to a support agent"
    Then :"that tower appears next to the support agent"
  end

  scenario "Non Admin is refused access to manage Agents" do
    Given :"I am not an admin"
    When :"I access the agent management page"
    Then :"I am not able to manage agents"
  end

protected

  def_Given :"I am an admin" do
    user.update!(roles: %w[admin])
  end

  def_Given :"I am not an admin" do
    # dont assign admin role
  end

  def_When :"I assign a tower to a support agent" do
    click_button "Agent Login"
    visit support_management_agents_path

    within "tr", text: "Test User" do
      select "ICT", from: "agent[support_tower_id]"
      click_on "Save"
    end
  end

  def_When :"I access the agent management page" do
    click_button "Agent Login"
    visit support_management_agents_path
  end

  def_Then :"that tower appears next to the support agent" do
    expect(support_agent.reload.support_tower).to eq(ict_tower)
  end

  def_Then :"I am not able to manage agents" do
    expect(page).not_to have_content("Test User")
    expect(page).to have_content("You do not have the required role to access this page")
  end
end
