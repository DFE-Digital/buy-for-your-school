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
      visit support_case_statistics_tower_path(id: "services")
    end

    describe "tower page content" do
      it "shows the number of cases by live state" do
        within(".tower-overview", text: "Live cases") { expect(page).to have_content("6") }
        within(".tower-overview", text: "Open") { expect(page).to have_content("2") }
        within(".tower-overview", text: "On hold") { expect(page).to have_content("2") }
        within(".tower-overview", text: "New") { expect(page).to have_content("2") }
      end

      it "shows main sections" do
        expect(page).to have_content("Live cases by stage")
        expect(page).to have_content("Live cases by level")
      end
    end
  end
end
