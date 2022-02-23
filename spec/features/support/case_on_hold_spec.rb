RSpec.feature "Case worker can place an open case on hold" do
  include_context "with an agent"

  let(:support_case) { create(:support_case, :opened, agent: agent, ref: "000001") }

  before do
    click_button "Agent Login"
    visit support_case_path(support_case)
    click_link "Place on hold"
  end

  it "redirects to the case" do
    expect(page).to have_current_path(support_case_path(support_case))
  end

  it "changes status of case to on hold" do
    support_case.reload
    expect(support_case.state).to eq "on_hold"
  end
end
