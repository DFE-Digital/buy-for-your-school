RSpec.feature "Case statistics tower page" do
  let(:services_tower) { create(:support_tower, title: "Services") }
  let(:category) { create(:support_category, title: "Books", tower: services_tower) }

  before do
    create(:support_case, :initial, category:)
    create(:support_case, :opened, category:)
    create(:support_case, :resolved, category:)
    create(:support_case, :closed, category:)
    create(:support_case, :on_hold, category:)
    create(:support_case, :initial, category: nil) # no tower
  end

  context "when the user is an admin" do
    include_context "with an agent"

    before do
      visit support_case_statistics_tower_path(id: "services")
    end

    describe "tower page content" do
      it "shows the number of cases by live state" do
        within(".tower-overview", text: "Live cases") { expect(page).to have_content("3") }
        within(".tower-overview", text: "Open") { expect(page).to have_content("1") }
        within(".tower-overview", text: "On hold") { expect(page).to have_content("1") }
        within(".tower-overview", text: "New") { expect(page).to have_content("1") }
      end

      context "when tower is not 'No Tower'" do
        it "links Live Cases to the tower page for this tower" do
          expect(page).to have_link(href: support_cases_path(anchor: "services-tower", tower: { "services-tower" => { filter_services_cases: { state: "live", override: "true" } } }), text: "3\nLive cases")
        end
      end

      context "when tower is 'No Tower'" do
        it "links Live Cases to the tower page for No tower" do
          visit support_case_statistics_tower_path(id: "no-tower")
          expect(page).to have_link(href: support_cases_path(anchor: "all-cases", filter_all_cases_form: { state: "live", tower: "no-tower" }), text: "1\nLive case")
        end
      end

      it "shows main sections" do
        expect(page).to have_content("Live cases by stage")
        expect(page).to have_content("Live cases by level")
      end
    end

    describe "tower page navigation" do
      it "links to a drilldown page showing relevant cases", js: true do
        # live Services cases in Need stage
        click_on "Need"
        expect(page).to have_text "Services Tower"
        expect(page).to have_text "000001"
        expect(page).to have_text "000002"
        expect(page).to have_text "000005"
      end
    end
  end
end
