require "rails_helper"

describe "User can update site contact details", :js do
  include_context "with energy suppliers"

  specify "Updating site contact" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    visit energy_case_org_site_contact_details_path(onboarding_case, case_organisation)

    expect(page).to have_text("Who manages site access and maintenance?")

    click_button "Save and continue"

    expect(page).to have_text("Enter first name")
    expect(page).to have_text("Enter last name")
    expect(page).to have_text("Enter email address")
    expect(page).to have_text("Enter telephone number")

    fill_in "First name", with: "123"
    click_button "Save and continue"
    expect(page).to have_text("Enter a valid first name")

    fill_in "First name", with: "Momo"
    click_button "Save and continue"
    expect(page).not_to have_text("Enter a valid first name")

    fill_in "Last name", with: "123"
    click_button "Save and continue"
    expect(page).to have_text("Enter a valid last name")

    fill_in "Last name", with: "Taro"
    click_button "Save and continue"
    expect(page).not_to have_text("Enter a valid last name")

    fill_in "Email", with: "123"
    click_button "Save and continue"
    expect(page).to have_text("Enter a valid email address")

    fill_in "Email", with: "test@test.com"
    click_button "Save and continue"
    expect(page).not_to have_text("Enter a valid email address")

    fill_in "Telephone", with: "123"
    click_button "Save and continue"
    expect(page).to have_text("Enter a valid telephone number")

    fill_in "Telephone", with: "01234567890"
    click_button "Save and continue"
    expect(page).not_to have_text("Enter a valid telephone number")
  end
end
