RSpec.feature "An authenticated user" do

  before do
    user_is_signed_in
    visit "/profile"
  end

  it "can navigate to edit their profile on DSI" do
    expect(page).to have_link "update your DfE Sign In account details",
      href: "https://test-profile.signin.education.gov.uk/edit-details",
      class: "govuk-link"
  end

  it "has a breadcrumb from the dashboard" do
    expect(page).to have_breadcrumbs ["Dashboard", "Profile"]
  end

end
