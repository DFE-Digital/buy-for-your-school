require "rails_helper"

describe "Case view" do
  include_context "with an agent"

  let(:support_case) { create(:support_case) }

  context "when case has an action required" do
    let(:support_case) { create(:support_case, :action_required) }

    it "shows action required status" do
      visit support_case_path(support_case)
      expect(page).to have_css(".case-status-badge", text: "Action")
    end
  end

  context "when the case is closed" do
    before do
      support_case.update!(state: :closed)
      visit support_case_path(support_case)
    end

    it "shows closed status" do
      expect(page).to have_css(".case-status-badge", text: "Closed")
    end

    it "has available actions" do
      expect(page).to have_css(".case-actions")
    end
  end
end
