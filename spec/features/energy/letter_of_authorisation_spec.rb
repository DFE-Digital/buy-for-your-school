require "rails_helper"

describe "Letter Of Authorisation Agreement", :js do
  include_context "with energy suppliers"

  before do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)
    # visit energy_case_letter_of_authorisation_path(case: onboarding_case)
    visit energy_case_letter_of_authorisation_path(case_id: case_organisation.energy_onboarding_case_id)
  end

  specify "Letter Of Authorisation description" do
    expect(page).to have_text("Appointment")
    expect(page).to have_text("Responsibilities")
    expect(page).to have_text("Invoices and billing")
    expect(page).to have_text("Non-payment of invoices and right to deduct funding")
    expect(page).to have_text(support_organisation.name)
  end

  specify "Updating LOA Agreement without selecting all boxes" do
    expect(page).to have_text("Agree to the Energy for Schools letter of authority")

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

  specify "Updating LOA Agreement with selecting all boxes" do
    expect(page).to have_text("Agree to the Energy for Schools letter of authority")

    checkboxes = all('input[type="checkbox"]')
    checkboxes.each(&:check)
    click_button "Continue"

    expect(page).not_to have_text("Select all boxes to continue")
    expect(page).not_to have_text("Agree to the Energy for Schools letter of authority")
  end
end
