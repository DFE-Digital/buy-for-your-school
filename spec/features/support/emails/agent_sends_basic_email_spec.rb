require "rails_helper"

describe "Support agent sends a basic email" do
  include_context "with an agent"

  let(:default_email_body) { "Thank you for getting in touch with the Get Help Buying For Schools team, and thank you for using our online service to create your catering specification." }
  let(:support_case) { create(:support_case, :open) }

  before do
    click_button "Agent Login"
    visit support_case_path(support_case)
    click_link "Send email"
  end

  describe "selecting a non-template email" do
    before do
      choose "Non-template"
      click_button "Save"
    end

    it "provides the user with a basic email body to customise" do
      expect(page).to have_field("Enter email body", text: default_email_body)
    end
  end

  describe "customisating the email body" do
    let(:custom_email_body) { "New email body" }

    before do
      choose "Non-template"
      click_button "Save"
      fill_in "Enter email body", with: custom_email_body
      click_button "Preview email"
    end

    it "shows the new email body on the preview screen" do
      within ".email-preview-body" do
        expect(page).to have_content("New email body")
      end
    end

    context "when leaving the email body blank" do
      let(:custom_email_body) { "" }

      it "displays an error" do
        expect(page).to have_content("Please enter an email body to be sent")
      end
    end
  end

  describe "previewing the email body" do
    before do
      choose "Non-template"
      click_button "Save"
      click_button "Preview email"
    end

    it "shows the email body" do
      within ".email-preview-body" do
        expect(page).to have_content(default_email_body)
      end
    end

    it "shows the correct subject and to address" do
      within ".email-preview" do
        expect(page).to have_content(support_case.email)
        expect(page).to have_content("DfE Get help buying for schools: your request for support")
      end
    end

    describe "navigating directly to the preview" do
      before { visit support_case_email_content_path(support_case, template: :basic) }

      it "shows the email body" do
        within ".email-preview-body" do
          expect(page).to have_content(default_email_body)
        end
      end

      it "shows the correct subject and to address" do
        within ".email-preview" do
          expect(page).to have_content(support_case.email)
          expect(page).to have_content("DfE Get help buying for schools: your request for support")
        end
      end
    end
  end

  describe "sending the email" do
    before do
      choose "Non-template"
      click_button "Save"
      fill_in "Enter email body", with: "New email body"
      click_button "Preview email"
      click_button "Confirm and send email"
    end

    it "saves the email as a case interaction" do
      interacton = support_case.reload.interactions.last

      expect(interacton.event_type).to eq("email_to_school")
      expect(interacton.body).to eq("New email body")
      expect(interacton.agent).to eq(agent)
    end
  end
end
