feature "Sign out" do
  let(:user) { create(:user, :caseworker, first_name: "Generic", last_name: "User", full_name: "Generic User") }
  let!(:agent) { Support::Agent.find_or_create_by_user(user).tap { |agent| agent.update!(roles: ["procops"]) } }

  context "when user is signed in" do
    before do
      Current.actor = agent
      user_exists_in_dfe_sign_in(user:)
      user_is_signed_in(user:)
      visit "/cms"
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
