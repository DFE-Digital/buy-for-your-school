RSpec.feature "Sign out" do
  let(:user) { create(:user, first_name: "Generic", last_name: "User", full_name: "Generic User") }

  context "when user is signed in" do
    before do
      user_is_signed_in(user:)

      visit "/dashboard"
    end

    it "destroys the session and returns you to the home page" do
      within("header") do
        expect(page).to have_link "Sign out", href: "/auth/dfe/signout", class: "govuk-header__link"
      end

      # generic.button.sign_out
      click_on "Sign out"

      expect(page).to have_current_path "/"

      expect(find("h3.govuk-notification-banner__heading")).to have_text "You have been signed out."
    end
  end

  context "when user is not signed in" do
    it "does not show the sign out link or user name in the header" do
      visit "/"

      within("header") do
        expect(page).not_to have_link "Sign out", href: "/auth/dfe/signout", class: "govuk-header__link"
        expect(page).not_to have_content "Signed in as Generic User"
      end
    end
  end
end
