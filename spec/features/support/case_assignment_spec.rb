RSpec.feature "Case worker assignment", js: true, bullet: :skip do
  include_context "with an agent"

  context "when re-assigning an agent to a case" do
    let(:support_case) { create(:support_case, :opened) }

    before do
      visit support_case_path(support_case)
      click_link "Change case owner"
      select_agent "Procurement Specialist"
      click_button "Assign"
    end

    it "assigns the agent and redirects to the case", flaky: true do
      expect(support_case.reload.agent).to eq(agent)
      expect(page).to have_current_path(support_case_path(support_case), ignore_query: true)
    end
  end

  def select_agent(term)
    fill_in "Search for caseworker name", with: term
    sleep 2
    find(".autocomplete__option", text: term).click
  end
end
