require "rails_helper"

describe "VAT certificate of declaration", :js do
  include_context "with energy suppliers"

  specify "Updating declaration" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    visit energy_case_org_vat_certificate_path(onboarding_case, case_organisation)

    expect(page).to have_text("VAT certificate of declaration")

    click_button "Continue"
    expect(page).to have_text("Select all boxes to continue")

    checkboxes = all('input[type="checkbox"]')
    checkboxes.first.check
    click_button "Continue"
    expect(page).to have_text("Select all boxes to continue")

    checkboxes = all('input[type="checkbox"]')
    checkboxes[1].check
    click_button "Continue"
    expect(page).to have_text("Select all boxes to continue")

    checkboxes = all('input[type="checkbox"]')
    checkboxes[2].check
    click_button "Continue"
    expect(page).not_to have_text("Select all boxes to continue")
  end
end
