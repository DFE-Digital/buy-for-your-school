RSpec.feature "Faf - start page" do
  xcontext "when the user is not signed in" do
    before do
      visit "/procurement-support"
    end

    it "loads the page" do
      expect(find("h1")).to have_text "Request advice and guidance for your procurement"
      expect(page).to have_current_path "/procurement-support"
    end

    it "navigates to the about frameworks page in an external tab" do
      url = "https://www.gov.uk/guidance/buying-procedures-and-procurement-law-for-schools/find-the-right-way-to-buy"
      expect(page).to have_link("about frameworks", href: url)
    end

    it "navigates to the planning for what you're buying page in an external tab" do
      url = "https://www.gov.uk/guidance/buying-for-schools"
      expect(page).to have_link("planning for what you're buying", href: url)
    end

    it "navigates to the finding the right way to buy page in an external tab" do
      url = "https://www.gov.uk/guidance/buying-procedures-and-procurement-law-for-schools"
      expect(page).to have_link("finding the right way to buy", href: url)
    end

    it "navigates to the create a specification page directly as an internal link" do
      expect(page).to have_link "create a specification", href: "/", class: "govuk-link"
    end
  end

  xcontext "when the user is signed in" do
    before do
      user_is_signed_in
      visit "/procurement-support"
    end

    it "loads the page" do
      expect(find("h1")).to have_text "Request advice and guidance for your procurement"
      expect(page).to have_current_path "/procurement-support"
    end

    it "navigates to the about frameworks page in an external tab" do
      url = "https://www.gov.uk/guidance/buying-procedures-and-procurement-law-for-schools/find-the-right-way-to-buy"
      expect(page).to have_link("about frameworks", href: url)
    end

    it "navigates to the planning for what you're buying page in an external tab" do
      url = "https://www.gov.uk/guidance/buying-for-schools"
      expect(page).to have_link("planning for what you're buying", href: url)
    end

    it "navigates to the finding the right way to buy page in an external tab" do
      url = "https://www.gov.uk/guidance/buying-procedures-and-procurement-law-for-schools"
      expect(page).to have_link("finding the right way to buy", href: url)
    end

    it "navigates to the create a specification page directly as an internal link" do
      expect(page).to have_link "create a specification", href: "/", class: "govuk-link"
    end
  end
end
