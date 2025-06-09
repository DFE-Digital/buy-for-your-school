require "rails_helper"

describe "CEC Admin can create a CEC staff member" do
  include_context "with an agent", roles: %w[cec_admin]

  scenario "CEC Admin creates a new agent and sets roles" do
    visit cec_root_path
    click_on "Management"
    click_on "Agents"
    click_on "New Agent"
    fill_in "First name", with: "Jane"
    fill_in "Last name", with: "Doe"
    fill_in "Email", with: "janedoe@education.gov.uk"
    check "CEC Staff Member"
    click_on "Save"

    within "tr", text: "Jane Doe" do
      expect(page).to have_content("CEC Staff Member")
    end
  end

  scenario "Agent with same email already exists" do
    agent = create(:support_agent, email: "janedoe@education.gov.uk", roles: [])

    visit cec_root_path
    click_on "Management"
    click_on "Agents"
    click_on "New Agent"
    fill_in "First name", with: "Jane"
    fill_in "Last name", with: "Doe"
    fill_in "Email", with: "janedoe@education.gov.uk"
    check "CEC Staff Member"
    click_on "Save"

    within "tr", text: "Jane Doe" do
      expect(page).to have_content("CEC Staff Member")
    end

    agent.reload
    expect(agent).to have_attributes(
      first_name: "Jane",
      last_name: "Doe",
      roles: %w[cec],
    )
  end
end
