RSpec.feature "Case worker assignment", js: true do
  include_context "with an agent"

  context "when re-assigning an agent to a case" do
    let(:support_case) { create(:support_case, :opened) }

    before do
      click_button "Agent Login"
      visit support_case_path(support_case)
      click_link "Change case owner"
      select_agent "Procurement Specialist"
      click_button "Assign"
    end

    it "redirects to the case in question" do
      expect(page).to have_current_path(support_case_path(support_case), ignore_query: true)
    end

    it "has the chosen agent now assigned to the case" do
      expect(support_case.reload.agent).to eq(agent)
    end
  end

  context "when case was previously not opened already" do
    let(:support_case) { create(:support_case, :initial) }

    before do
      click_button "Agent Login"
      visit support_case_path(support_case)
      click_link "Assign to case worker"
      select_agent "Procurement Specialist"
      click_button "Assign"
    end

    it "records a 'case_opened' action" do
      expect(Support::ActivityLogItem.where(action: "open_case", support_case_id: support_case.id).count).to eq(1)
    end

    it "sets the case status to opened" do
      expect(support_case.reload).to be_opened
    end

    it "redirects to the case in question" do
      expect(page).to have_current_path(support_case_path(support_case), ignore_query: true)
    end

    it "has the chosen agent now assigned to the case" do
      expect(support_case.reload.agent).to eq(agent)
    end
  end

  context "when there are internal agents" do
    let(:support_case) { create(:support_case, :initial) }

    before do
      create(:support_agent, first_name: "Internal", last_name: "Agent", internal: true)
      click_button "Agent Login"
      visit support_case_path(support_case)
      click_link "Assign to case worker"
    end

    it "does not show them in the caseworker list" do
      fill_in "case_assignment_form[agent_name]", with: "Internal Agent"
      sleep 0.5
      expect(page).not_to have_selector(".autocomplete__option", text: "Internal Agent")
    end
  end

  def select_agent(term)
    fill_in "case_assignment_form[agent_name]", with: term
    sleep 0.5
    find(".autocomplete__option", text: term)&.click
  end
end
