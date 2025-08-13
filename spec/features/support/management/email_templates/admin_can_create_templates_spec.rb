require "rails_helper"

describe "Admin can create email templates", :js, :with_csrf_protection do
  include_context "with an agent", roles: %w[global_admin]

  before do
    energy = create(:support_email_template_group, title: "Energy")
    create(:support_email_template_group, title: "Solar", parent: energy)

    cec = create(:support_email_template_group, title: "CEC")
    create(:support_email_template_group, title: "DfE Energy for Schools service", parent: cec)

    system_group = create(:support_email_template_group, title: "System")
    create(:support_email_template_group, title: "DfE Energy for Schools", parent: system_group)
    create(:support_email_template_group, title: "Document sharing", parent: system_group)
    create(:support_email_template_group, title: "Other", parent: system_group)
  end

  describe "Admin viewing email templates selects to create a new template" do
    before do
      visit support_management_email_templates_path
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

  describe "Admin can view CEC template group" do
    before do
      visit support_management_email_templates_path
      click_on "Create new template"
      select "CEC", from: "Template group"
    end

    it "view DfE Energy for Schools service" do
      subgroup_field = find("#email-template-form-subgroup-id-field")
      expect(subgroup_field).to have_selector("option", text: "DfE Energy for Schools service")
    end
  end

  describe "Admin can view System template group" do
    before do
      visit support_management_email_templates_path
      click_on "Create new template"
      select "System", from: "Template group"
    end

    it "view System sub groups" do
      subgroup_field = find("#email-template-form-subgroup-id-field")
      expect(subgroup_field).to have_selector("option", text: "DfE Energy for Schools")
      expect(subgroup_field).to have_selector("option", text: "Document sharing")
      expect(subgroup_field).to have_selector("option", text: "Other")
    end
  end
end
