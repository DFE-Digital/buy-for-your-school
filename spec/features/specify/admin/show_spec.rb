feature "Admin page" do
  # Rollbar shows this feature is not used... phasing out
  context "when the user is an analyst" do
    include_context "with an agent", roles: %w[analyst]

    before { visit "/admin" }

    it "shows the page content", flaky: true do
      expect(page).to have_title "User activity data"

      within "tr", text: "Total number of users" do
        expect(page).to have_content("1")
      end

      within "tr", text: "Total number of specifications" do
        expect(page).to have_content("0")
      end

      within "tr", text: "Last user registration date" do
        expect(page).to have_content(user.created_at.strftime("%-d %B %Y"))
      end
    end
  end
end
