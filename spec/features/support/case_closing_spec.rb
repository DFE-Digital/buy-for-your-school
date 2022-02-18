RSpec.feature "Case worker can close a case" do
  include_context "with an agent"

  let(:support_case) { create(:support_case, :resolved) }

  before do
    click_button "Agent Login"
    visit support_case_path(support_case)
    click_link "Close case"
  end

  it "redirects to the case" do
    expect(page).to have_current_path(support_case_path(support_case), ignore_query: true)
  end

  it "changes status of case to closed" do
    support_case.reload
    expect(support_case.state).to eq "closed"
  end
  
end