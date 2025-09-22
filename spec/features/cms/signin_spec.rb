require "rails_helper"

describe "GET CMS path", :js do
  include_context "with an agent"
  let(:support_case) { create(:support_case) }

  specify "redirects to the cms my cases path" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)
    visit cms_signin_path
    click_button "Sign in"
    expect(page).to have_text("My cases")
  end
end
