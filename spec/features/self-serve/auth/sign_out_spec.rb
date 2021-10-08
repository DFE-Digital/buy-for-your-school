RSpec.feature "Sign out" do
  let(:user) { create(:user, first_name: "Generic", last_name: "User", full_name: "Generic User") }
  
  before do
    user_is_signed_in(user: user)

    visit "/dashboard"
  end

  it "destroys the session and returns you to the home page" do
    within("header") do
      expect(page).to have_link "Sign out", href: "/auth/dfe/signout", class: "govuk-header__link"
    end

    # generic.button.sign_out
    click_on "Sign out"

    # or mimic failure
    # visit "/auth/failure"

    expect(page.driver.request.session.keys).to be_empty
    expect(page).to have_current_path "/"

    expect(find("h3.govuk-notification-banner__heading")).to have_text "You have been signed out."

    # FIXME: why is the signout link still visible in this spec?
    # within("header") do
    #   expect(page).not_to have_link "Sign out", href: "/auth/dfe/signout", class: "govuk-header__link"
    #   expect(page).not_to have_content "Signed in as Generic User"
    # end
  end
end
