require "rails_helper"

describe "Agent sees emails in messages", js: true do
  include_context "with an agent"

  let(:is_read) { true }
  let(:email) { create(:support_email, :inbox, ticket: support_case, subject: "Catering requirements", is_read:) }
  let(:support_case) { create(:support_case) }

  before do
    create(:support_interaction, :email_from_school,
           body: email.body,
           additional_data: { email_id: email.id },
           case: support_case)

    visit support_case_path(support_case)
    click_link "Messages"
    within("#messages-frame") { click_link "View" }
  end

  context "when email is unread" do
    let(:is_read) { false }

    it "displays UNREAD next to the interaction in messages" do
      within "#messages .message-details" do
        expect(page).to have_css(".email-read-status", text: "Unread")
      end
    end

    it "allows to mark the email as read" do
      click_link "Mark as read"
      sleep 0.5
      expect(page).to have_css(".email-read-status", text: "Read")
    end
  end

  context "when email is read" do
    it "displays READ next to the interaction in messages" do
      within "#messages .message-details" do
        expect(page).to have_css(".email-read-status", text: "Read")
      end
    end

    it "allows to mark the email as unread" do
      click_link "Mark as unread"
      sleep 0.5
      expect(page).to have_css(".email-read-status", text: "Unread")
    end
  end
end
