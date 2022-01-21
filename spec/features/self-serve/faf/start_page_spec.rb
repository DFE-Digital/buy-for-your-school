RSpec.feature "Faf - start page" do
  context "when the user is not signed in" do
    before do
      visit "/procurement-support"
    end

    it "loads the page" do
      expect(find("h1")).to have_text "Request help and support with your procurement"
      expect(page).to have_current_path "/procurement-support"
    end

    it "navigates to the about frameworks page" do
      expect(page).to have_link "about frameworks", href: "https://www.gov.uk/guidance/buying-for-schools", class: "govuk-link"
    end

    it "navigates to the planning for what you're buying page" do
      expect(page).to have_link "planning for what you're buying", href: "https://www.gov.uk/guidance/buying-procedures-and-procurement-law-for-schools", class: "govuk-link"
    end

    it "navigates to the finding the right way to buy page" do
      expect(page).to have_link "finding the right way to buy", href: "https://www.gov.uk/guidance/buying-procedures-and-procurement-law-for-schools", class: "govuk-link"
    end

    it "navigates to the create a specification page" do
      expect(page).to have_link "create a specification", href: "/dashboard", class: "govuk-link"
    end
  end

  context "when the user is signed in" do
    before do
      user_is_signed_in
      visit "/procurement-support"
    end

    it "loads the page" do
      expect(find("h1")).to have_text "Request help and support with your procurement"
      expect(page).to have_current_path "/procurement-support"
    end

    it "navigates to the about frameworks page" do
      expect(page).to have_link "about frameworks", href: "https://www.gov.uk/guidance/buying-for-schools", class: "govuk-link"
    end

    it "navigates to the planning for what you're buying page" do
      expect(page).to have_link "planning for what you're buying", href: "https://www.gov.uk/guidance/buying-procedures-and-procurement-law-for-schools", class: "govuk-link"
    end

    it "navigates to the finding the right way to buy page" do
      expect(page).to have_link "finding the right way to buy", href: "https://www.gov.uk/guidance/buying-procedures-and-procurement-law-for-schools", class: "govuk-link"
    end

    it "navigates to the create a specification page" do
      expect(page).to have_link "create a specification", href: "/dashboard", class: "govuk-link"
    end
  end
end
