RSpec.feature "Admin page" do
  before do
    user_exists_in_dfe_sign_in(user: user)
    visit "/"
    click_start
    visit "/admin"
  end

  context "when the user is an analyst" do
    let(:user) { create(:user, :analyst) }

    it "shows the page content" do
      expect(find("h1.govuk-heading-l")).to have_text "Admin"
    end

    it "reports access to Rollbar" do
      expect(Rollbar).to receive(:info).with("User role has been granted access.", role: "analyst", path: "/admin")
      visit "/admin"
    end
  end

  context "when the user is not an analyst" do
    let(:user) { create(:user) }

    it "shows a missing role error" do
      expect(find("h1.govuk-heading-l")).to have_text "Missing user role"
      expect(find("p.govuk-body")).to have_text "You do not have the required role to access this page."
    end
  end
end
