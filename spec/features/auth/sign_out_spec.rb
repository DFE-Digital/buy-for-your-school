RSpec.feature "Sign out" do
  # let(:user) { create(:user) }
  # let(:dsi_uid) { user.dfe_sign_in_uid }

  it "destroys the session and returns you to the home page" do
    user_is_signed_in
    # user_exists_in_dfe_sign_in(dsi_uid: dsi_uid)

    visit "/dashboard"

    within("header") do
      expect(page).to have_link "Sign out", href: "/auth/dfe/signout", class: "govuk-header__link"
    end

    # generic.button.sign_out
    click_on "Sign out"

    expect(page.driver.request.session.keys).to be_empty
    expect(page).to have_current_path "/"

    # FIXME: why is the signout link still visible?
    # within("header") do
    #   expect(page).not_to have_link "Sign out", href: "/auth/dfe/signout", class: "govuk-header__link"
    # end
  end
end
