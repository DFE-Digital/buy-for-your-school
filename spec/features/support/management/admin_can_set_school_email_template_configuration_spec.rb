require "rails_helper"

describe "Admin can set Support email template configurations" do
  include_context "with an agent", roles: %w[global_admin]
  before do
    system_group = create(:support_email_template_group, title: "System")
    dfe_group = create(:support_email_template_group, title: "DfE Energy for Schools", parent: system_group)
    create(:support_email_template, title: "Template 1", template_group_id: dfe_group.id)
    create(:support_email_template, title: "Template 2", template_group_id: dfe_group.id)
  end

  scenario "Admin sets emails to" do
    visit support_management_energy_for_schools_path

    expect(page).to have_text("Energy for Schools")
    expect(page).to have_text("Electricity supplier emails")
    expect(page).to have_text("Gas supplier emails")
    expect(page).to have_text("Schools emails")

    within first(".govuk-summary-card") do
      within first(".govuk-summary-list__row") do
        within all(".govuk-summary-list__actions")[0] do
          click_link "Change"
        end
      end
    end

    expect(page).to have_text("Send electricity emails to")
    click_button "Save and return"
    expect(page).to have_text("Enter at least one email address")
    fill_in "Send electricity emails to", with: "test"
    click_button "Save and return"
    expect(page).to have_text("Please enter valid email addresses separated by semicolons")
    fill_in "Send electricity emails to", with: "test@test.com; test"
    click_button "Save and return"
    expect(page).to have_text("Please enter valid email addresses separated by semicolons")
    fill_in "Send electricity emails to", with: "test@test.com; test2@test.com"
    click_button "Save and return"
    expect(page).to have_text("Email configuration updated successfully")

    within first(".govuk-summary-card") do
      within first(".govuk-summary-list__row") do
        within all(".govuk-summary-list__value")[0] do
          expect(page).to have_text("test@test.com")
        end
      end
    end
  end

  scenario "Admin sets template" do
    visit support_management_energy_for_schools_path

    within first(".govuk-summary-card") do
      within all(".govuk-summary-list__row")[1] do
        within all(".govuk-summary-list__actions")[0] do
          click_link "Change"
        end
      end
    end

    expect(page).to have_text("Electricity supplier Form submitted")
    expect(page).to have_text("Template 1")
    click_button "Save and return"
    expect(page).to have_text("Select any one email template")
    choose "Template 1"
    click_button "Save and return"
    expect(page).to have_text("Email configuration updated successfully")
  end
end
