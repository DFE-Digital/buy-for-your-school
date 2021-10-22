RSpec.feature "Case worker assignment" do
  include_context "with an agent"

  let(:support_case) { create(:support_case, :open) }

  before do
    click_button "Agent Login"
    visit support_case_path(support_case)
    click_link "Change case owner"
  end

  it "displays a title" do
    expect(page).to have_content("Assign to case worker")
  end

  context "when assigning an agent to a case" do
    before do
      choose "Procurement Specialist"
      click_button "Assign"
    end

    it "redirects to the case in question" do
      expect(page).to have_current_path(support_case_path(support_case), ignore_query: true)
    end

    it "sets the case status to open" do
      expect(support_case.reload).to be_open
    end

    it "has the chosen agent now assigned to the case" do
      expect(support_case.reload.agent).to eq(agent)
    end
  end
end
