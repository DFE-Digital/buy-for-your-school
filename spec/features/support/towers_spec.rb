RSpec.feature "Case statistics tower page" do
  before do
    category = create(:support_category, title: "Books", with_tower: "Services")

    create(:support_case, :initial, category:)
    create(:support_case, :opened, category:)
    create(:support_case, :resolved, category:)
    create(:support_case, :closed, category:)
    create(:support_case, :on_hold, category:)
  end

  context "when the user is an admin" do
    include_context "with an agent"

    before do
      click_button "Agent Login"
      visit support_case_statistics_tower_path(id: "services")
    end

    describe "tower page content" do
      it "shows the number of cases by live state" do
        within(".tower-overview", text: "Live cases") { expect(page).to have_content("3") }
        within(".tower-overview", text: "Open") { expect(page).to have_content("1") }
        within(".tower-overview", text: "On hold") { expect(page).to have_content("1") }
        within(".tower-overview", text: "New") { expect(page).to have_content("1") }
      end

      it "shows main sections" do
        expect(page).to have_content("Live cases by stage")
        expect(page).to have_content("Live cases by level")
      end
    end
  end
end
