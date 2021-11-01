require "rails_helper"

describe "Support agent sends a templated email" do
  include_context "with an agent"
  include_context "with notify email templates"

  let(:support_case) { Support::CasePresenter.new(create(:support_case, :open)) }

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
        expect(page).to have_content("Hi #{support_case.full_name}, here is information regarding frameworks")
      end
    end
  end

  describe "sending the email" do
    before do
      click_link "What is a framework?"
      click_button "Confirm and send email"
    end

    it "saves the email as a case interaction" do
      interacton = support_case.reload.interactions.last

      expect(interacton.event_type).to eq("email_to_school")
      expect(interacton.body).to eq("Hi #{support_case.full_name}, here is information regarding frameworks")
      expect(interacton.agent).to eq(agent)
    end
  end
end
