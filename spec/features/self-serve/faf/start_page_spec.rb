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
      click_link "about frameworks"
      expect(find("h1")).to have_text ""
      expect(page).to have_current_path "/guidance/buying-procedures-and-procurement-law-for-schools/find-the-right-way-to-buy"
    end

    it "navigates to the planning for what you're buying page" do
      click_link "planning for what you're buying"
      expect(find("h1")).to have_text "Buying for schools"
      expect(page).to have_current_path "/beta/phase-6/gov/buying-for-schools"
    end

    it "navigates to the finding the right way to buy page" do
      click_link "finding the right way to buy"
      expect(find("h1")).to have_text "Buying procedures and procurement law for schools"
      expect(page).to have_current_path "/beta/phase-6/gov/buying-procedures-for-schools"
    end

    it "navigates to the create a specification page" do
      click_link "finding the right way to buy"
      expect(find("h1")).to have_text "Create a specification to procure for your school"
      expect(page).to have_current_path "https://get-help-buying-for-schools.education.gov.uk/"
    end
  end

  context "when the user is signed in" do
    before do
      user_is_signed_in
      visit "/procurement-support"
    end

    it "loads the page" do
      expect(find("h1")).to have_text "Request help and support with your procurement"
      xpect(page).to have_current_path "/procurement-support"
    end

    it "navigates to the about frameworks page" do
      click_link "about frameworks"
      expect(find("h1")).to have_text ""
      expect(page).to have_current_path "/guidance/buying-procedures-and-procurement-law-for-schools/find-the-right-way-to-buy"
    end

    it "navigates to the planning for what you're buying page" do
      click_link "planning for what you're buying"
      expect(find("h1")).to have_text "Buying for schools"
      expect(page).to have_current_path "/beta/phase-6/gov/buying-for-schools"
    end

    it "navigates to the finding the right way to buy page" do
      click_link "finding the right way to buy"
      expect(find("h1")).to have_text "Buying procedures and procurement law for schools"
      expect(page).to have_current_path "/beta/phase-6/gov/buying-procedures-for-schools"
    end

    it "navigates to the create a specification page" do
      click_link "finding the right way to buy"
      expect(find("h1")).to have_text "Create a specification to procure for your school"
      expect(page).to have_current_path "https://get-help-buying-for-schools.education.gov.uk/"
    end
  end
end

