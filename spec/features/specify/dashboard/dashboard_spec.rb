RSpec.feature "Specification dashboard" do
  context "when the user is not signed in" do
    before do
      visit "/dashboard"
    end

    it "redirects to the hompage" do
      expect(page).to have_current_path cms_signin_path
      expect(page).to have_content "You must sign in"
    end
  end

  context "when the user is signed in" do
    before do
      user_is_signed_in
      visit "/dashboard"
    end

    it "displays the list of existing specs" do
      expect(page).to have_title "Specifications dashboard"
    end
  end
end
