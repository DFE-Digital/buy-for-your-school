require "rails_helper"

describe "Agent can view other cases raised by the same organisation" do
  include_context "with an agent"

  let(:organisation) { create(:support_organisation, name: "Test School") }

  describe "In the case tabs view" do
    context "when there are no other cases raised by the same organisation" do
      before do
        create(:support_case, agent:, organisation:)
        create(:support_case, agent:, state: :closed, organisation:)
        visit "/support/cases#my-cases"
      end

      it "does not display the 'View all' link" do
        within("#my-cases .case-panel") do
          expect(page).not_to have_text("Other cases")
          expect(page).not_to have_text("View all")
        end
      end
    end

    context "when there are other cases raised by the same organisation" do
      before do
        create(:support_case, agent:, organisation:)
        create(:support_case, state: :opened, organisation:)
        create(:support_case, state: :resolved, organisation:)
        visit "/support/cases#my-cases"
      end

      it "displays the 'View all' link" do
        within("#my-cases .case-panel") do
          expect(page).to have_text("Other cases")
          expect(page).to have_text("View all")
        end
      end
    end
  end

  describe "In the individual case view", :js do
    let!(:support_case) { create(:support_case, agent:, organisation:) }

    context "when there are no other cases raised by the same organisation" do
      before do
        create(:support_case, agent:, state: :closed, organisation:)
        visit "/support/cases/#{support_case.id}#school-details"
      end

      it "does not display the 'View all cases' link" do
        within("#school-details") do
          expect(page).not_to have_text("View all cases")
        end
      end
    end

    context "when there are other cases raised by the same organisation" do
      before do
        create(:support_case, state: :opened, organisation:)
        create(:support_case, state: :resolved, organisation:)
        visit "/support/cases/#{support_case.id}#school-details"
      end

      it "displays the 'View all cases' link" do
        within("#school-details") do
          expect(page).to have_text("View all cases")
        end
      end
    end
  end
end
