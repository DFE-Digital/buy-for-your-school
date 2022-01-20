require "rails_helper"

describe "Case view" do
  include_context "with an agent"

  let(:support_case) { create(:support_case) }

  before { click_button "Agent Login" }

  context "when case has an action required" do
    let(:support_case) { create(:support_case, :action_required) }

    it "shows action required status" do
      visit support_case_path(support_case)
      expect(page).to have_css(".case-status-badge", text: "Action")
    end
  end
end
