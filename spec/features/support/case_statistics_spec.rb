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
      visit "/support/case-statistics"
    end

    describe "case statistics page content" do
      it "has the correct title and h1" do
        expect(page).to have_title "Case statistics"
        expect(find("h1.govuk-heading-l")).to have_text "Case statistics"
      end

      it "shows the correct number of live cases" do
        expect(page).to have_css ".no_of_live_cases", text: "25"
      end

      it "shows the number of cases by live state" do
        expect(page).to have_css ".opened-live-cases", text: "8"
        expect(page).to have_css ".on-hold-live-cases", text: "8"
        expect(page).to have_css ".initial-live-cases", text: "9"
      end

      it "displays the number of cases in a combined procops tower by state" do
        within ".overview-by-tower" do
          expect(page).to have_text "FM and Catering"
          expect(page).to have_css ".FM-and-Catering-live-cell", text: "9"
          expect(page).to have_css ".FM-and-Catering-initial-cell", text: "3"
          expect(page).to have_css ".FM-and-Catering-opened-cell", text: "3"
          expect(page).to have_css ".FM-and-Catering-on_hold-cell", text: "3"
        end
      end

      it "displays the number of cases in a single procops tower by state" do
        within ".overview-by-tower" do
          expect(page).to have_text "ICT"
          expect(page).to have_css ".ICT-live-cell", text: "3"
          expect(page).to have_css ".ICT-initial-cell", text: "1"
          expect(page).to have_css ".ICT-opened-cell", text: "1"
          expect(page).to have_css ".ICT-on_hold-cell", text: "1"
        end
      end

      it "displays the number of cases with no tower by state" do
        within ".overview-by-tower" do
          expect(page).to have_text "No tower"
          expect(page).to have_css ".no-tower-live-cell", text: "1"
          expect(page).to have_css ".no-tower-initial-cell", text: "1"
          expect(page).to have_css ".no-tower-opened-cell", text: "0"
          expect(page).to have_css ".no-tower-on_hold-cell", text: "0"
        end
      end

      it "redirects to a drilldown page for a particular tower" do
        click_on "Services"
        expect(page).to have_text "Services Statistics"
      end

      it "has a link to download the CSV of the case data" do
        expect(page).to have_link "Download CSV", class: "govuk-button", href: "/support/case-statistics.csv"
      end

      it "reports access to Rollbar" do
        expect(Rollbar).to receive(:info).with("User role has been granted access.", role: "agent", path: "/support/case-statistics")
        visit "/support/case-statistics"
      end

      it "provides a case data CSV download" do
        expect(Rollbar).to receive(:info).with("Case data downloaded.")
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
      visit "/support/case-statistics"
    end

    context "and the user is an analyst" do
      let(:user) { create(:user, :analyst, created_at: Time.zone.parse("2021-12-20")) }

      it "shows the page content" do
        expect(page).to have_title "Case statistics"
      end

      it "reports access to Rollbar" do
        expect(Rollbar).to receive(:info).with("User role has been granted access.", role: "analyst", path: "/support/case-statistics")
        visit "/support/case-statistics"
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
