RSpec.feature "Case worker can open a case" do
  include_context "with an agent"

  before do
    click_button "Agent Login"
    visit support_case_path(support_case)
    click_link "Reopen case"
  end

  context "when re-opening a case" do
    let(:support_case) { create(:support_case, :resolved) }

    it "redirects to the case" do
      expect(page).to have_current_path(support_case_path(support_case), ignore_query: true)
    end

    it "changes status of case to opened" do
      support_case.reload
      expect(support_case.state).to eq "opened"
    end
  end

  context "when a case is on hold" do
    let(:support_case) { create(:support_case, state: :on_hold) }

    it "redirects to the case" do
      expect(page).to have_current_path(support_case_path(support_case), ignore_query: true)
    end

    it "changes status of case to opened" do
      support_case.reload
      expect(support_case.state).to eq "opened"
    end
  end
end
