require "rails_helper"

describe "User can update site contact details", :js do
  include_context "with energy suppliers"
  include_context "with awkward space characters"

  specify "Updating site contact" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    visit energy_case_org_site_contact_details_path(onboarding_case, case_organisation)

    expect(page).to have_text("Who manages site access and maintenance?")
    fill_in "Email", with: ""
    fill_in "Telephone", with: ""

    click_button "Save and continue"

    expect(page).to have_text("Enter a first name")
    expect(page).to have_text("Enter an email address")
    expect(page).to have_text("Enter a telephone number")
    expect(page).to have_link("Discard and go to task list", href: energy_case_tasks_path(case_id: onboarding_case.id))

    fill_in "First name", with: "Momo"
    click_button "Save and continue"
    expect(page).not_to have_text("Enter a first name")

    fill_in "Email", with: "123"
    click_button "Save and continue"
    expect(page).to have_text("Enter an email address in the correct format, like jo.wade@school.org.uk")

    fill_in "Email", with: "test@test.com"
    click_button "Save and continue"
    expect(page).not_to have_text("Enter an email address in the correct format, like jo.wade@school.org.uk")

    fill_in "Telephone", with: "123"
    click_button "Save and continue"
    expect(page).to have_text("Enter a telephone number, like 07155487611")

    fill_in "Telephone", with: "01234567890"
    click_button "Save and continue"
    expect(page).not_to have_text("Enter a telephone number, like 07155487611")

    visit energy_case_org_site_contact_details_path(onboarding_case, case_organisation)
    fill_in "Telephone", with: "(44)#{non_breaking_space}1234-567890"
    click_button "Save and continue"
    expect(page).not_to have_text("Enter a telephone number, like 07155487611")
  end
end
