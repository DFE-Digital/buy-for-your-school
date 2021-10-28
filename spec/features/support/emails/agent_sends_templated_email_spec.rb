require "rails_helper"

describe "Support agent sends a templated email" do
  include_context "with an agent"
  include_context "with notify email templates"

  let(:support_case) { create(:support_case, :open) }

  before do
    click_button "Agent Login"
    visit support_case_path(support_case)
    click_link "Send email"
    choose "Template"
    click_button "Save"
  end

  describe "list of templates" do
    it "displays all available email templates to choose from" do
      available_email_templates.each do |email_template|
        expect(page).to have_link(email_template.name, href: support_case_email_content_path(support_case, template: email_template.id))
      end
    end
  end

  describe "selecting a template" do
    before { click_link "What is a framework?" }

    it "previews the email with variables substituted" do
      within ".email-preview" do
        expect(page).to have_content("Hi #{support_case.contact.first_name} #{support_case.contact.last_name}, here is information regarding frameworks")
      end
    end
  end
end
