require "rails_helper"

describe "Agent can message from within an evaluation", js: true do
  include_context "with a framework evaluation agent"

  let(:evaluation) { create(:frameworks_evaluation, reference: "FE123", contact:) }
  let(:contact) { create(:frameworks_provider_contact, email: "contact@email.com") }

  def message_double(body)
    double(
      id: "1",
      subject: "",
      body: double(content: body),
      unique_body: double(content: body),
      from: double(email_address: double(address: "", name: "")),
      to_recipients: [double(email_address: double(address: contact.email, name: contact.name))],
      cc_recipients: [],
      bcc_recipients: [],
      sent_date_time: Time.zone.now,
      received_date_time: nil,
      internet_message_id: "",
      conversation_id: "1",
      has_attachments: false,
      is_read: false,
      is_draft: false,
      in_reply_to_id: "",
    )
  end

  describe "replying to a recieved email" do
    before do
      create(:email, :inbox, ticket: evaluation, subject: "Reply to this please", outlook_conversation_id: "1")

      allow(MicrosoftGraph).to receive(:client).and_return(double(create_and_send_new_reply: message_double("This is a test reply"), get_file_attachments: []))
    end

    it "displays the reply on the thread" do
      visit frameworks_evaluation_path(evaluation)
      go_to_tab "Messages"
      within "tr", text: "Reply to this please" do
        click_link "View"
      end
      click_button "Reply to message"

      fill_in_editor "Your message", with: "This is a test reply"
      click_button "Send reply"
      expect(page).to have_css(".message-preview", text: "This is a test reply")
    end
  end

  describe "sending a new message" do
    before do
      allow(MicrosoftGraph).to receive(:client).and_return(double(create_and_send_new_message: message_double("My new message"), get_file_attachments: []))
    end

    it "displays the new email thread" do
      visit frameworks_evaluation_path(evaluation)
      go_to_tab "Messages"
      click_button "Create a new message thread"

      expect(page).to have_field "Enter an email subject", with: "[FE123] - DfE Get help buying for schools"
      expect(page).to have_css '[data-row-label="TO"]', text: "contact@email.com"

      fill_in_editor "Your message", with: "My new message"
      click_button "Send message"

      expect(page).to have_css(".message-preview", text: "My new message")
      find("details", text: "Display recipients").click
      expect(page).to have_content("To: contact@email.com")
    end
  end
end
