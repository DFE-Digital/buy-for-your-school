require "rails_helper"

RSpec.feature "Admin can edit email templates", :js, :with_csrf_protection do
  include_context "with an agent", roles: %w[global_admin]

  scenario "Admin views and edits templates" do
    energy = create(:support_email_template_group, title: "Energy")
    solar = create(:support_email_template_group, title: "Solar", parent: energy)
    create(:support_email_template_group, title: "General")
    template = create(
      :support_email_template,
      group: solar, stage: 3, title: "New template",
      description: "This is a new email template",
      subject: "New template subject", body: "Body of new template"
    )

    visit support_management_email_templates_path
    click_on "Edit"

    attach_file Rails.root.join("spec/fixtures/files/text-file.txt"),
                class: "dz-hidden-input", make_visible: true
    expect(page).to have_content("text-file.txt")

    select "General", from: "Template group"
    select "Stage 0", from: "Stage (optional)"
    fill_in "Template name", with: "Edited template"
    fill_in "Template guidance", with: "This is an edited template"
    fill_in "Subject line for email (optional)", with: "Edited template subject"
    click_button "Save updates"

    expect(page).to have_content("Updates to your template have been saved")
    expect(page).to have_content("1 template")

    expect(page).to have_content("Edited template")
    expect(page).to have_content("This is an edited template")
    expect(page).to have_content("General")
    expect(page).to have_content("Stage 0")
    expect(page).to have_content("Edited template subject")
    expect(page).to have_content("Body of new template")

    expect(template.reload.attachments.count).to eq(1)

    click_on "Edit"
    click_button "Save updates"
    expect(page).to have_content("Updates to your template have been saved")
    expect(template.reload.attachments.count).to eq(1)
  end
end
