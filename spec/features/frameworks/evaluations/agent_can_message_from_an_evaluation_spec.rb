require "rails_helper"

describe "Agent can message from within an evaluation", js: true do
  include_context "with a framework evaluation agent"

  let(:evaluation) { create(:frameworks_evaluation, reference: "FE123", contact:) }
  let(:contact) { create(:frameworks_provider_contact, email: "contact@email.com") }

  describe "replying to a recieved email" do
    before do
      create(:email, :inbox, ticket: evaluation, subject: "Reply to this please")

      created_message = double.as_null_object
      allow(MicrosoftGraph).to receive(:client).and_return(created_message)
      allow(Email).to receive(:cache_message).with(created_message, anything) do
        create(:email, body: "This is a test reply", unique_body: "This is a test reply", ticket: evaluation)
      end
    end

    it "displays the reply on the thread" do
      visit frameworks_evaluation_path(evaluation)
      go_to_tab "Messages"
      within "tr", text: "Reply to this please" do
        click_link "View"
      end

      fill_in_editor "Your message", with: "This is a test reply"
      click_button "Send reply"
      expect(page).to have_css(".message-preview", text: "This is a test reply")
    end
  end

  describe "sending a new message" do
    before do
      created_message = double.as_null_object
      allow(MicrosoftGraph).to receive(:client).and_return(created_message)
      allow(Email).to receive(:cache_message).with(created_message, anything) do
        create(:email, body: "My new message", unique_body: "My new message", ticket: evaluation, recipients: [{ address: "contact@email.com" }])
      end
    end

    it "displays the new email thread" do
      visit frameworks_evaluation_path(evaluation)
      go_to_tab "Messages"
      click_link "Create a new message thread"

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
