RSpec.feature "Admin page" do
  # Rollbar shows this feature is not used... phasing out
  context "when the user is an analyst" do
    include_context "with an agent", roles: %w[analyst]

    before { visit "/admin" }

    it "shows the page content" do
      expect(page).to have_title "User activity data"
      expect(find("h1.govuk-heading-l")).to have_text "User activity data"
      expect(all("th.govuk-table__header")[0]).to have_text "Total number of users"
      expect(all("td.govuk-table__cell")[0]).to have_text "1"
      expect(all("th.govuk-table__header")[1]).to have_text "Total number of specifications"
      expect(all("td.govuk-table__cell")[1]).to have_text "0"
      expect(all("th.govuk-table__header")[2]).to have_text "Last user registration date"
      expect(all("td.govuk-table__cell")[2]).to have_text user.created_at.strftime("%d %B %Y")
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
    include_context "with an agent"

    before { visit "/admin" }

    it "shows not authorised error" do
      expect(page).to have_current_path(cms_not_authorized_path, ignore_query: true)
    end
  end
end
