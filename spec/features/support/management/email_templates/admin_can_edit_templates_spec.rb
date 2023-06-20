require "rails_helper"

describe "Admin can edit email templates", :with_csrf_protection, js: true do
  include_context "with an agent", roles: %w[global_admin]

  before do
    energy = create(:support_email_template_group, title: "Energy")
    solar = create(:support_email_template_group, title: "Solar", parent: energy)
    create(:support_email_template_group, title: "General")
    create(:support_email_template, group: solar, stage: 3, title: "New template", description: "This is a new email template", subject: "New template subject", body: "Body of new template")
  end

  describe "Admin viewing email templates selects to edit an existing template" do
    before do
      visit support_management_email_templates_path
      click_on "Edit"

      select "General", from: "Template group"
      select "Stage 0", from: "Stage (optional)"
      fill_in "Template name", with: "Edited template"
      fill_in "Template guidance", with: "This is an edited template"
      fill_in "Subject line for email (optional)", with: "Edited template subject"
      click_button "Save updates"
    end

    it "shows the edited template" do
      expect(page).to have_content("Updates to your template have been saved")
      expect(page).to have_content("1 template")

      expect(page).to have_content("Edited template")
      expect(page).to have_content("This is an edited template")
      expect(page).to have_content("General")
      expect(page).to have_content("Stage 0")
      expect(page).to have_content("Edited template subject")
      expect(page).to have_content("Body of new template")
    end
  end
end
