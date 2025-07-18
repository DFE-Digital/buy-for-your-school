require "rails_helper"

describe "CEC Admin can create email templates", :js, :with_csrf_protection do
  include_context "with an agent", roles: %w[global_admin]

  before do
    energy = create(:support_email_template_group, title: "Energy")
    create(:support_email_template_group, title: "Solar", parent: energy)
  end

  describe "CEC Admin viewing email templates selects to create a new template" do
    before do
      visit cec_management_email_templates_index_path
      click_on "Create new template"

      select "Energy", from: "Template group"
      select "Solar", from: "Subgroup (optional)"
      select "Stage 3", from: "Stage (optional)"
      fill_in "Template name", with: "New template"
      fill_in "Template guidance", with: "This is a new email template"
      fill_in "Subject line for email (optional)", with: "New template subject"
      click_button "Create template"
    end

    it "shows the created template" do
      expect(page).to have_content("Your template has been saved")
      expect(page).to have_content("1 template")

      expect(page).to have_content("New template")
      expect(page).to have_content("This is a new email template")
      expect(page).to have_content("Energy")
      expect(page).to have_content("Solar")
      expect(page).to have_content("Stage 3")
      expect(page).to have_content("New template subject")
      expect(page).to have_content("Procurement Specialist")
    end
  end
end
