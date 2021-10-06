RSpec.feature "Specification dashboard" do
  context "when the user is not signed in" do
    before do
      visit "/dashboard"
    end

    it "redirects to the hompage" do
      expect(page).to have_current_path "/"
    end

    it "has no breadcrumbs component" do
      expect(page).not_to have_css(".govuk-breadcrumbs")
    end

    it "has a back link button" do
      expect(page).not_to have_css(".govuk-back-link")
    end

    it "specifying.start_page.page_title" do
      expect(page.title).to have_text "Create a specification to procure for your school"
    end

    it "renders a banner notice" do
      expect(find("h2.govuk-notification-banner__title")).to have_text "Notice"
      expect(find("h3.govuk-notification-banner__heading")).to have_text "You must sign in."
    end
  end

  context "when the user is signed in" do
    before do
      user_is_signed_in
      visit "/dashboard"
    end

    it "offers support with requests" do
      expect(page).to have_link "Request free help and support with your specification", href: "/profile" # , class: "govuk-link"
    end
  end
end
