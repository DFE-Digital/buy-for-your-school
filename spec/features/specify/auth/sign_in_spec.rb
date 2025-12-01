RSpec.feature "DfE Sign-in" do
  context "with valid DfE Sign In credentials" do
    let(:user) { create(:user, first_name: "Generic", last_name: "User") }

    before do
      user_exists_in_dfe_sign_in(user:)
      visit "/"
      click_start
    end

    it "signs in and goes to dashboard" do
      expect(page).to have_content "Signed in as Generic User"
      expect(page).to have_title "Specifications dashboard"
    end
  end
end
