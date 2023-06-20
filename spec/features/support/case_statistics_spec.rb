RSpec.feature "Case statistics page" do
  before do
    categories = { "ICT" => %w[Laptops],
                   "Energy & Utilities" => %w[Electricity Water],
                   "Services" => %w[Gas] }

    categories.each do |tower, cats|
      cats.each do |cat|
        category = create(:support_category, title: cat, with_tower: tower)

        create(:support_case, :initial, category:)
        create(:support_case, :opened, category:)
        create(:support_case, :resolved, category:)
        create(:support_case, :closed, category:)
        create(:support_case, :on_hold, category:)
      end
    end

    # support case with no category (and therefore no tower)
    create(:support_case, :initial, category: nil)
  end

  context "when the user is an admin" do
    include_context "with an agent", roles: %w[global_admin]

    before do
      visit support_case_statistics_path
    end

    describe "case statistics page content" do
      it "shows the number of cases by live state" do
        within(".case-overview", text: "Live cases") { expect(page).to have_content("13") }
        within(".case-overview", text: "Open") { expect(page).to have_content("4") }
        within(".case-overview", text: "On hold") { expect(page).to have_content("4") }
        within(".case-overview", text: "New") { expect(page).to have_content("5") }
      end

      it "displays each tower in an overview by tower section" do
        within ".overview-by-tower" do
          expect(page).to have_css("tr", text: "Energy & Utilities")
          expect(page).to have_css("tr", text: "ICT")
          expect(page).to have_css("tr", text: "Services")
          expect(page).to have_css("tr", text: "No Tower")
        end
      end
    end

    describe "case statistics navigation" do
      it "links to a drilldown page for a particular tower" do
        click_on("Services", match: :first)
        expect(page).to have_text "Services Statistics"
      end

      it "links to a drilldown page showing relevant cases", js: true do
        # 6 live cases in Energy & Utilities
        within(".overview-by-tower") { click_on("6") }
        expect(page).to have_text "Energy & Utilities Tower"
        expect(page).to have_text "000011"
        expect(page).to have_text "000006"
        expect(page).to have_text "000012"
        expect(page).to have_text "000007"
        expect(page).to have_text "000015"
        expect(page).to have_text "000010"
      end
    end

    describe "case statistics downloads" do
      it "has a link to download the CSV of the case data" do
        expect(page).to have_link "Download CSV", class: "govuk-button", href: support_case_statistics_path(format: :csv)
      end

      it "provides a case data CSV download" do
        click_on "Download CSV"
        expect(page.response_headers["Content-Type"]).to eq "text/csv"
        expect(page.response_headers["Content-Disposition"]).to match(/^attachment/)
        expect(page.response_headers["Content-Disposition"]).to match(/filename="case_data.csv"/)
      end
    end
  end
end
