RSpec.feature "An authenticated user" do
  subject(:user) { create(:user, first_name: "Peter", last_name: "Hamilton") }

  before do
    user_is_signed_in(user: user)
    visit "/profile"
  end

  it "has a breadcrumb from the dashboard" do
    expect(page).to have_breadcrumbs %w[Dashboard Profile]
  end

  it "can navigate to edit their profile on DSI" do
    expect(page).to have_link "update your DfE Sign In account details",
                              href: "https://test-profile.signin.education.gov.uk/edit-details",
                              class: "govuk-link"
  end

  describe "About you" do
    it "confirms contact information" do
      expect(find("span.govuk-caption-l")).to have_text "About you"
      expect(find("h1.govuk-heading-l")).to have_text "Is this your contact information?"

      expect(find("a.govuk-button")).to have_text "Request support"

      # expect(page).to have_link "Exit without saving", href: "/dashboard"
    end
  end
end
