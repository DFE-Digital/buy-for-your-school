require "rails_helper"

describe "School selection", :js do
  include_context "with energy suppliers"
  specify "Information submitted screen" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    visit energy_case_confirmation_path(case_id: case_organisation.energy_onboarding_case_id)

    expect(page).to have_text("Information submitted")
    expect(page).to have_text("We’ve sent an email to #{onboarding_case.support_case&.email} containing a copy of this form and details about your new contract.")
    expect(page).to have_text("Depending on your contract’s end date, you may be placed on an interim rate to ensure continued supply to your school.")

    click_link "What did you think of this service?"
    expect(page).to have_text("Get help buying for schools feedback")
    expect(page).to have_text("Thank you for taking the time to give us your feedback.")
  end
end
