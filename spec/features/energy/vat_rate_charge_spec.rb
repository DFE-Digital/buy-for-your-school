require "rails_helper"

describe "VAT rate charge", :js do
  let(:support_organisation) { create(:support_organisation, urn: 100_253) }
  let(:user) { create(:user, :many_supported_schools_and_groups) }
  let(:support_case) { create(:support_case, organisation: support_organisation) }
  let(:onboarding_case) { create(:onboarding_case, support_case:) }
  let(:case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case:, onboardable: support_organisation) }

  let(:valid_vat_reg_no) { "123456789" }
  let(:invalid_vat_reg_no) { "123" }
  let(:percentage) { "55" }
  let(:invalid_percentage) { "abc" }

  before do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    visit energy_case_org_vat_rate_charge_path(onboarding_case, case_organisation)
  end

  specify "Selecting 20% VAT rate" do
    expect(page).to have_text("Which VAT rate are you charged?")
    expect(page).to have_link("Discard and go to task list", href: energy_case_tasks_path(case_id: onboarding_case.id))

    click_button "Save and continue"
    expect(page).to have_text("Select a VAT rate")
    choose "20%"
    click_button "Save and continue"
    expect(page).not_to have_text("Select a VAT rate")

    expect(case_organisation.reload.vat_rate).to eq(20)
  end

  specify "Selecting 5% VAT rate" do
    expect(page).to have_text("Which VAT rate are you charged?")
    choose "5%"
    click_button "Save and continue"
    expect(page).to have_text("Enter the percentage qualifying for reduced VAT")
    expect(page).not_to have_text("Enter a VAT registration number")

    fill_in "Percentage of total consumption qualifying for reduced rate of VAT", with: invalid_percentage
    fill_in "VAT registration number (optional)", with: invalid_vat_reg_no
    click_button "Save and continue"
    expect(page).to have_text("Enter a value between 1 and 100")
    expect(page).to have_text("Enter a VAT registration number that's 9 digits long, like 123456789")

    fill_in "Percentage of total consumption qualifying for reduced rate of VAT", with: percentage
    fill_in "VAT registration number (optional)", with: valid_vat_reg_no
    click_button "Save and continue"
    expect(page).not_to have_text("Enter a value between 1 and 100")
    expect(page).not_to have_text("Enter a VAT registration number that's 9 digits long, like 123456789")

    expect(case_organisation.reload.vat_rate).to eq(5)
    expect(case_organisation.vat_lower_rate_percentage.to_s).to eq(percentage)
    expect(case_organisation.vat_lower_rate_reg_no).to eq(valid_vat_reg_no)
  end

  specify "Selecting 20% VAT rate after setting some 5% fields already" do
    expect(page).to have_text("Which VAT rate are you charged?")
    choose "5%"
    fill_in "Percentage of total consumption qualifying for reduced rate of VAT", with: 7
    fill_in "VAT registration number (optional)", with: valid_vat_reg_no
    click_button "Save and continue"
    expect(page).to have_text("Are these the correct details for VAT purposes?")
    choose "Yes"
    click_button "Save and continue"
    expect(page).to have_text("VAT certificate of declaration")
    click_on "Back"
    expect(page).to have_text("Are these the correct details for VAT purposes?")
    click_on "Back"
    expect(page).to have_text("Which VAT rate are you charged?")
    choose "20%"
    click_button "Save and continue"

    expect(case_organisation.reload.vat_rate).to eq(20)
    expect(case_organisation.vat_lower_rate_percentage).to eq(nil)
    expect(case_organisation.vat_lower_rate_reg_no).to eq(nil)
    expect(case_organisation.vat_person_correct_details).to eq(nil)
    expect(case_organisation.vat_person_first_name).to eq(nil)
    expect(case_organisation.vat_person_phone).to eq(nil)
    expect(case_organisation.vat_person_address).to eq(nil)
  end
end
