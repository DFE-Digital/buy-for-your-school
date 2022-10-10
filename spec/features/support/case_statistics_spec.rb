RSpec.feature "Case statistics page" do
  before do
    categories = { "ICT": %w[Laptops],
                   "Energy & Utilities": %w[Electricity Water],
                   "FM": ["Waste management"],
                   "Catering": %w[Catering],
                   "Furniture": %w[Furniture],
                   "Business Services": %w[Books],
                   "Professional Services": %w[HR] }

    categories.each do |tower, cats|
      cats.each do |cat|
        category = create(:support_category, title: cat, tower:)

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
    include_context "with an agent"

    before do
      click_button "Agent Login"
      visit support_case_statistics_path
    end

    describe "case statistics page content" do
      it "shows the number of cases by live state" do
        within(".case-overview", text: "Live cases") { expect(page).to have_content("25") }
        within(".case-overview", text: "Open") { expect(page).to have_content("8") }
        within(".case-overview", text: "On hold") { expect(page).to have_content("8") }
        within(".case-overview", text: "New") { expect(page).to have_content("9") }
      end

      it "displays each tower in an overview by tower section" do
        within ".overview-by-tower" do
          expect(page).to have_css("tr", text: "Energy and Utilities")
          expect(page).to have_css("tr", text: "FM and Catering")
          expect(page).to have_css("tr", text: "ICT")
          expect(page).to have_css("tr", text: "Services")
          expect(page).to have_css("tr", text: "No Tower")
        end
      end
    end

    describe "case statistics navigation" do
      it "links to a drilldown page for a particular tower" do
        click_on "Services"
        expect(page).to have_text "Services Statistics"
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

  context "when the user is not an admin" do
    before do
      user_exists_in_dfe_sign_in(user:)
      visit "/"
      click_start
      visit support_case_statistics_path
    end

    context "and the user is an analyst" do
      let(:user) { create(:user, :analyst, created_at: Time.zone.parse("2021-12-20")) }

      it "shows the page content" do
        expect(page).to have_title "Case statistics"
      end
    end

    context "and the user is not an analyst" do
      let(:user) { create(:user) }

      it "shows a missing role error" do
        expect(page).to have_title "Missing user role"
        expect(find("h1.govuk-heading-l")).to have_text "Missing user role"
        expect(find("p.govuk-body")).to have_text "You do not have the required role to access this page."
      end
    end
  end
end
