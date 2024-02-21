RSpec.feature "Starting a 'Find a Framework' request" do
  before do
    visit "/procurement-support"
  end

  it "loads without requiring authentication" do
    expect(page).to have_current_path "/procurement-support"
  end

  it "links to the homepage" do
    expect(page).to have_link "create a specification", href: "/", class: "govuk-link"
  end

  describe "for authenticated users", js: true do
    before do
      user_exists_in_dfe_sign_in

      visit "/procurement-support"
      click_on "Start now"
      choose "Yes, use my DfE Sign-in"
      click_continue
    end

    it "shows their profile", flaky: true do
      expect(page).to have_current_path "/procurement-support/confirm_sign_in"
      expect(page).to have_button "Yes, continue"
    end

    describe "when user signs out" do
      before do
        click_on "Sign out"
      end

      it "redirects to the start page" do
        expect(page).to have_current_path "/procurement-support"
        expect(page).to have_content "You have been signed out."
      end
    end
  end
end
