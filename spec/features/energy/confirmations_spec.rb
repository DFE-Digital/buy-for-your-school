require "rails_helper"

describe "School selection", :js do
  include_context "with energy suppliers"
  specify "Information submitted screen" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    visit energy_case_org_confirmation_path(onboarding_case, case_organisation)

    expect(page).to have_text("Information submitted")
    expect(page).to have_text("We've sent you an email containing a copy of this form and details about your new contract.")
    expect(page).to have_text("Depending on your contract’s end date, you may be placed on an interim contract to ensure continued supply to your school.")
  end
end
