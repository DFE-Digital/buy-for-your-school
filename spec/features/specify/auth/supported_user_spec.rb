feature "User authentication filter" do
  before do
    user_exists_in_dfe_sign_in(user:)
  end

  context "when the user is not associated with any organisation" do
    let(:user) { build(:user, orgs: nil) }

    before do
      dsi_client = instance_double(::Dsi::Client)
      allow(Dsi::Client).to receive(:new).and_return(dsi_client)
      allow(dsi_client).to receive(:orgs).and_raise(::Dsi::Client::ApiError)
      visit "/"
      click_start
    end

    it "informs the user" do
      expect(page).to have_content "You are not associated with an organisation"
      expect(page).to have_link "log into your DfE Sign-In account and select your organisation."
      expect(page).to have_text("You need to be associated with an organisation before you can use this service")
    end
  end

  context "when the user is associated with an unsupported organisation" do
    let(:user) { build(:user, :no_supported_schools) }

    before do
      visit "/"
      click_start
    end

    it "informs the user" do
      expect(page).to have_content "Your organisation is not supported by this service"
    end
  end
end
