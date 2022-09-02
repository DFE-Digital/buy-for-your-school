RSpec.feature "Case statistics tower page" do
  before do
    categories = { "Business Services": "Books",
                   "Professional Services": "HR" }

    categories.each do |tower, cat|
      category = create(:support_category, title: cat, tower:)
      procurement = create(:support_procurement)

      create(:support_case, :initial, category:, support_level: 0, procurement:)
      create(:support_case, :opened, category:, support_level: 1, procurement:)
      create(:support_case, :resolved, category:)
      create(:support_case, :closed, category:)
      create(:support_case, :on_hold, category:, support_level: 2, procurement:)
    end
  end

  context "when the user is an admin" do
    include_context "with an agent"

    before do
      click_button "Agent Login"
      visit "/support/case-statistics/tower/Services"
    end

    describe "tower page content" do
      it "has the correct title and h1" do
        expect(find("h1.govuk-heading-l")).to have_text "Services Statistics"
      end

      it "has a back link that goes to the case statistics page" do
        click_on "Back"
        expect(page).to have_current_path "/support/case-statistics"
      end

      it "shows the correct number of live cases" do
        expect(page).to have_css ".no_of_live_cases", text: "6"
      end

      it "shows the number of cases by live state" do
        expect(page).to have_css ".opened-live-cases", text: "2"
        expect(page).to have_css ".on-hold-live-cases", text: "2"
        expect(page).to have_css ".initial-live-cases", text: "2"
      end

      it "displays the number of cases in a single tower by state and procurement stage" do
        within ".overview-by-stage" do
          expect(page).to have_css ".need-initial-cell", text: "2"
          expect(page).to have_css ".need-opened-cell", text: "2"
          expect(page).to have_css ".need-on_hold-cell", text: "2"
          expect(page).to have_css ".handover-initial-cell", text: "0"
          expect(page).to have_css ".handover-opened-cell", text: "0"
          expect(page).to have_css ".handover-on_hold-cell", text: "0"
        end
      end

      it "displays the number of cases in a single tower by state and support level" do
        within ".overview-by-level" do
          expect(page).to have_css ".L1-initial-cell", text: "2"
          expect(page).to have_css ".L2-opened-cell", text: "2"
          expect(page).to have_css ".L3-on_hold-cell", text: "2"
        end
      end
    end
  end
end
