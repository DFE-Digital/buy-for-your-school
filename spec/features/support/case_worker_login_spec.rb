RSpec.feature "Case worker authentication" do
  include_context "with an agent"

  it "has a title" do
    expect(page).to have_title "Supported Buying Case Management"
  end

  it "has a heading" do
    expect(find("h1.govuk-heading-xl")).to have_text "Supported Buying Case Management"
  end

  context "when the agent is whitelisted" do
    it "authenticates" do
      click_button "Agent Login"

      expect(page).to have_current_path "/support/cases"
    end
  end

  context "when the agent is not whitelisted" do
    let(:org_name) { "Not in the ProcOps team" }

    it "fails to gain access" do
      click_button "Agent Login"

      expect(page).not_to have_current_path "/support/cases"
      expect(page).to have_current_path "/support"
      expect(find("h3.govuk-notification-banner__heading")).to have_text "Invalid Caseworker"
    end
  end
end
