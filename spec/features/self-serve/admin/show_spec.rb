RSpec.feature "Admin page" do
  before do
    user_exists_in_dfe_sign_in(user: user)
    visit "/"
    click_start
    visit "/admin"
  end

  context "when the user is an analyst" do
    let(:user) { create(:user, :analyst, created_at: Time.zone.parse("2021-12-20")) }

    it "shows the page content" do
      expect(page).to have_title "User activity data"
      expect(find("h1.govuk-heading-l")).to have_text "User activity data"
      expect(all("th.govuk-table__header")[0]).to have_text "Total number of users"
      expect(all("td.govuk-table__cell")[0]).to have_text "1"
      expect(all("th.govuk-table__header")[1]).to have_text "Total number of specifications"
      expect(all("td.govuk-table__cell")[1]).to have_text "0"
      expect(all("th.govuk-table__header")[2]).to have_text "Last user registration date"
      expect(all("td.govuk-table__cell")[2]).to have_text "20 December 2021"
      expect(all("h1.govuk-heading-m")[0]).to have_text "Activity log"
      expect(page).to have_link "Download (.csv)", class: "govuk-button", href: "/admin/download/user_activity.csv"
      expect(page).to have_link "Download (.json)", class: "govuk-button", href: "/admin/download/user_activity.json"
      expect(all("h1.govuk-heading-m")[1]).to have_text "Users"
      expect(page).to have_link "Download (.json)", class: "govuk-button", href: "/admin/download/users.json"
    end

    it "reports access to Rollbar" do
      expect(Rollbar).to receive(:info).with("User role has been granted access.", role: "analyst", path: "/admin")
      visit "/admin"
    end

    it "provides an activity log CSV download" do
      expect(Rollbar).to receive(:info).with("User activity data downloaded.")
      click_on "Download (.csv)"
      expect(page.response_headers["Content-Type"]).to eq "text/csv"
      expect(page.response_headers["Content-Disposition"]).to match(/^attachment/)
      expect(page.response_headers["Content-Disposition"]).to match(/filename="user_activity_data.csv"/)
    end

    it "provides an activity log JSON download" do
      expect(Rollbar).to receive(:info).with("User activity data downloaded.")
      click_link "Download (.json)", href: "/admin/download/user_activity.json"
      expect(page.response_headers["Content-Type"]).to eq "application/json"
      expect(page.response_headers["Content-Disposition"]).to match(/^attachment/)
      expect(page.response_headers["Content-Disposition"]).to match(/filename="user_activity_data.json"/)
    end

    it "provides a users JSON download" do
      expect(Rollbar).to receive(:info).with("User data downloaded.")
      click_link "Download (.json)", href: "/admin/download/users.json"
      expect(page.response_headers["Content-Type"]).to eq "application/json"
      expect(page.response_headers["Content-Disposition"]).to match(/^attachment/)
      expect(page.response_headers["Content-Disposition"]).to match(/filename="user_data.json"/)
    end
  end

  context "when the user is not an analyst" do
    let(:user) { create(:user) }

    it "shows a missing role error" do
      expect(page).to have_title "Missing user role"
      expect(find("h1.govuk-heading-l")).to have_text "Missing user role"
      expect(find("p.govuk-body")).to have_text "You do not have the required role to access this page."
    end
  end
end
