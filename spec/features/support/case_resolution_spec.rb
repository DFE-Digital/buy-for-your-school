require "rails_helper"

describe "Resolving a case" do
  include_context "with an agent"

  let(:support_case) { create(:support_case, :open, agent: build(:support_agent)) }

  before do
    click_button "Agent Login"
    visit support_case_path(support_case)
    click_link "Resolve case"
  end

  context "when providing notes" do
    let(:case_resolved_interaction) { support_case.reload.interactions.last }

    before do
      fill_in "Resolve case", with: "A note when resolving the case"
      click_button "Save and close case"
    end

    it "resolves the case" do
      expect(support_case.reload).to be_resolved
    end

    it "saves the given note to the case" do
      expect(case_resolved_interaction.body).to eq("Case resolved: A note when resolving the case")
    end

    it "sets the current agent on the case note" do
      expect(case_resolved_interaction.agent).to eq(agent)
    end

    it "unassigns the existing agent from the case" do
      expect(support_case.reload.agent).to be_nil
    end

    it "redirects the user back to the case" do
      expect(page).to have_current_path(support_case_path(support_case), ignore_query: true)
    end
  end

  context "when not providing notes" do
    before do
      click_button "Save and close case"
    end

    it "remains open" do
      expect(support_case.reload).to be_open
    end

    it "tells the user to provide notes" do
      expect(page).to have_content("Please enter some closing notes to resolve the case")
    end
  end
end
