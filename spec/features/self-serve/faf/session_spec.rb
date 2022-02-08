RSpec.feature "FaF session" do
  let(:user) { create(:user, first_name: "Generic", last_name: "User", full_name: "Generic User") }

  context "when user is signed in", js: true do
    before do
      user_exists_in_dfe_sign_in(user: user)

      visit "/procurement-support"
      click_on "Start now"
      choose "Yes, use my DfE Sign-in"
      click_continue
    end

    it "shows their profile" do
      expect(page).to have_current_path "/profile"
    end

    # xit "user has one org" do
    #   # /procurement-support/new?step=5
    # end

    # xit "user has many orgs" do
    #   # /procurement-support/new?step=4
    # end

    context "when user signs out" do
      before do
        click_on "Sign out"
      end

      it "redirects them to step 1 of FaF form" do
        expect(page).to have_current_path "/procurement-support"
        expect(find("h3.govuk-notification-banner__heading")).to have_text "You have been signed out."
      end
    end
  end
end
