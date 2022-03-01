RSpec.feature "Admin page" do
  before do
    category = create(:support_category, title: "OS software")
    create(:support_case, :initial, category: category)
    create(:support_case, :opened, category: category)
    create(:support_case, :resolved, category: category)
    create(:support_case, :closed, category: category)
    create(:support_case, :pending, category: category)
  end

  context "when the user is an admin" do
    include_context "with an agent"

    before do
      click_button "Agent Login"
      visit "/support/admin"
    end

    it "shows the page content" do
      expect(page).to have_title "Case statistics"
      expect(find("h1.govuk-heading-l")).to have_text "Case statistics"
      expect(all("th.govuk-table__header")[0]).to have_text "Number of cases"
      expect(all("td.govuk-table__cell")[0]).to have_text "5"

      expect(all("h2.govuk-heading-m")[0]).to have_text "Number of cases by state"
      expect(all("th.govuk-table__header")[1]).to have_text "New"
      expect(all("td.govuk-table__cell")[1]).to have_text "1"
      expect(all("th.govuk-table__header")[2]).to have_text "Open"
      expect(all("td.govuk-table__cell")[2]).to have_text "1"
      expect(all("th.govuk-table__header")[3]).to have_text "Resolved"
      expect(all("td.govuk-table__cell")[3]).to have_text "1"
      expect(all("th.govuk-table__header")[4]).to have_text "Pending"
      expect(all("td.govuk-table__cell")[4]).to have_text "1"
      expect(all("th.govuk-table__header")[5]).to have_text "Closed"
      expect(all("td.govuk-table__cell")[5]).to have_text "1"

      expect(all("h2.govuk-heading-m")[1]).to have_text "Number of cases by category and state"
      expect(all("th.govuk-table__header")[6]).to have_text "OS software"
      expect(all("th.govuk-table__header")[7]).to have_text "New"
      expect(all("td.govuk-table__cell")[6]).to have_text "1"
      expect(all("th.govuk-table__header")[8]).to have_text "Open"
      expect(all("td.govuk-table__cell")[7]).to have_text "1"
      expect(all("th.govuk-table__header")[9]).to have_text "Resolved"
      expect(all("td.govuk-table__cell")[8]).to have_text "1"
      expect(all("th.govuk-table__header")[10]).to have_text "Pending"
      expect(all("td.govuk-table__cell")[9]).to have_text "1"
      expect(all("th.govuk-table__header")[11]).to have_text "Closed"
      expect(all("td.govuk-table__cell")[10]).to have_text "1"
      expect(all("th.govuk-table__header")[12]).to have_text "No category"
      expect(all("th.govuk-table__header")[13]).to have_text "New"
      expect(all("td.govuk-table__cell")[11]).to have_text "0"
      expect(all("th.govuk-table__header")[14]).to have_text "Open"
      expect(all("td.govuk-table__cell")[12]).to have_text "0"
      expect(all("th.govuk-table__header")[15]).to have_text "Resolved"
      expect(all("td.govuk-table__cell")[13]).to have_text "0"
      expect(all("th.govuk-table__header")[16]).to have_text "Pending"
      expect(all("td.govuk-table__cell")[14]).to have_text "0"
      expect(all("th.govuk-table__header")[17]).to have_text "Closed"
      expect(all("td.govuk-table__cell")[15]).to have_text "0"
      expect(page).to have_link "Download CSV", class: "govuk-button", href: "/support/admin/download/cases.csv"
    end

    it "reports access to Rollbar" do
      expect(Rollbar).to receive(:info).with("User role has been granted access.", role: "agent", path: "/support/admin")
      visit "/support/admin"
    end

    it "provides an activity log CSV download" do
      expect(Rollbar).to receive(:info).with("Case data downloaded.")
      click_on "Download CSV"
      expect(page.response_headers["Content-Type"]).to eq "text/csv"
      expect(page.response_headers["Content-Disposition"]).to match(/^attachment/)
      expect(page.response_headers["Content-Disposition"]).to match(/filename="case_data.csv"/)
    end
  end

  context "when the user is not an admin" do
    before do
      user_exists_in_dfe_sign_in(user: user)
      visit "/"
      click_start
      visit "/support/admin"
    end

    context "and the user is an analyst" do
      let(:user) { create(:user, :analyst, created_at: Time.zone.parse("2021-12-20")) }

      it "shows the page content" do
        expect(page).to have_title "Case statistics"
      end

      it "reports access to Rollbar" do
        expect(Rollbar).to receive(:info).with("User role has been granted access.", role: "analyst", path: "/support/admin")
        visit "/support/admin"
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
