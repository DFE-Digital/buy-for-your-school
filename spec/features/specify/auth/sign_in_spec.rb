feature "DfE Sign-in" do
  context "with valid DfE Sign In credentials" do
    let(:user) { create(:user, :caseworker, first_name: "Generic", last_name: "User") }
    let!(:agent) { Support::Agent.find_or_create_by_user(user).tap { |agent| agent.update!(roles: %w[procops]) } }

    before do
      user_exists_in_dfe_sign_in(user:)
      user_is_signed_in(user:)
      visit support_cases_path
    end

    it "signs in and shows CMS" do
      expect(page).to have_content "Signed in as Generic User"
    end
  end
end
