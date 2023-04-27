require "rails_helper"

describe "Admin can see a list of email templates", bullet: :skip do
  include_context "with an agent"

  before do
    user.update!(admin: true)
    create(:support_email_template, title: "MFD template")
    create(:support_email_template, title: "FM template")
    create(:support_email_template, title: "Archived template", archived: true)
  end

  describe "Admin viewing email templates page sees all templates listed" do
    before do
      click_button "Agent Login"
      visit support_management_email_templates_path
    end

    it "shows active templates" do
      expect(page).to have_content("MFD template")
      expect(page).to have_content("FM template")
      expect(page).not_to have_content("Archived template")
    end
  end
end
