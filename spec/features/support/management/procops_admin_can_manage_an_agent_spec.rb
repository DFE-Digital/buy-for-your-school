require "rails_helper"

RSpec.describe "ProcOps Admin role management" do
  include_context "with an agent", roles: %w[procops_admin]

  let(:roles) do
    [
      "Procurement Operations Admin",
      "Procurement Operations Staff Member",
      "CEC Staff Member",
      "CEC Admin",
    ]
  end

  scenario "procops admin can create an agent and sees all ProcOps + CEC roles" do
    visit support_management_agents_path
    click_on "New Agent"

    roles.each do |role|
      expect(page).to have_unchecked_field(role)
    end

    fill_in "First name", with: "Jane"
    fill_in "Last name", with: "Doe"
    fill_in "Email", with: "jane.doe@education.gov.uk"
    check "Procurement Operations Staff Member"
    click_on "Save"

    within "tr", text: "Jane Doe" do
      expect(page).to have_content("Procurement Operations Staff Member")
    end
  end

  scenario "procops admin can create an agent and assign CEC roles" do
    visit support_management_agents_path
    click_on "New Agent"

    fill_in "First name", with: "Test"
    fill_in "Last name", with: "User"
    fill_in "Email", with: "test.user@education.gov.uk"
    check "CEC Staff Member"
    click_on "Save"

    within "tr", text: "Test User" do
      expect(page).to have_content("CEC Staff Member")
    end
  end

  scenario "procops admin can edit an agent and sees all ProcOps + CEC roles" do
    agent = create(:support_agent, first_name: "John", last_name: "Smith", roles: [])

    visit edit_support_management_agent_path(agent)

    roles.each do |role|
      expect(page).to have_unchecked_field(role)
    end

    check "Procurement Operations Admin"
    click_on "Save"

    agent.reload
    expect(agent.roles).to include("procops_admin")
  end

  scenario "procops admin can edit an agent and assign CEC roles" do
    agent = create(:support_agent, first_name: "first", last_name: "last", roles: [])

    visit edit_support_management_agent_path(agent)

    check "CEC Admin"
    click_on "Save"

    agent.reload
    expect(agent.roles).to include("cec_admin")
  end

  scenario "procops admin can edit an agent but can't assign both CEC and ProcOps roles" do
    agent = create(:support_agent, first_name: "A", last_name: "B", roles: [])

    visit edit_support_management_agent_path(agent)

    check "CEC Admin"
    check "Procurement Operations Admin"
    click_on "Save"

    expect(page).to have_text("Other roles cannot be included when 'CEC Staff Member' and/or 'CEC Admin' is selected")
  end
end
