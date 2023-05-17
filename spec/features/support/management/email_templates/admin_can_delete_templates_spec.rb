require "rails_helper"

describe "Admin can delete email templates", js: true do
  include_context "with an agent", roles: %w[global_admin]

  before do
    energy = create(:support_email_template_group, title: "Energy")
    solar = create(:support_email_template_group, title: "Solar", parent: energy)
    create(:support_email_template, group: solar, stage: 3, title: "New template", description: "This is a new email template", subject: "New template subject", body: "Body of new template")
  end

  describe "Admin viewing email templates selects to delete a template" do
    before do
      visit support_management_email_templates_path
      accept_confirm { click_on "Delete" }
    end

    it "no longer shows the deleted template" do
      expect(page).to have_content("Your template has been deleted")
      expect(page).to have_content("0 templates")

      expect(page).not_to have_content("New template")
    end
  end
end
