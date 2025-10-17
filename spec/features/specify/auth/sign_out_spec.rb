feature "Sign out" do
  let(:user) { create(:user, first_name: "Generic", last_name: "User", full_name: "Generic User") }

  context "when user is signed in" do
    before do
      user_is_signed_in(user:)
      visit "/dashboard"
    end

    describe "when the user clicks log out" do
      it "logs the user out and returns them to the home page" do
        click_on "Sign out"
        expect(page).to have_content "You have been signed out"
        expect(page).to have_current_path cms_signin_path
      end
    end
  end
end
