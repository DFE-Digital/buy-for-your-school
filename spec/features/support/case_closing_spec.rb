RSpec.feature "Case worker can close a case" do
  include_context "with an agent"

  let(:support_case) { create(:support_case, :resolved, agent: agent, ref: "000001") }

  before do
    click_button "Agent Login"
    visit support_case_path(support_case)
    click_link "Close case"
  end

  it "redirects to the case" do
    expect(page).to have_current_path(support_case_path(support_case))
  end

  it "changes status of case to closed" do
    support_case.reload
    expect(support_case.state).to eq "closed"
  end

  it "removes the case from my cases tab" do
    visit support_cases_path
    expect(page).not_to have_css("#my-cases .case-row", text: "000001")

    within "#all-cases .case-row", text: "000001" do
      expect(page).to have_css(".case-status", text: "Closed")
    end
  end
end
