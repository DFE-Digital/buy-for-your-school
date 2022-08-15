describe "Agent can send new emails" do
  include_context "with an agent"

  let(:support_case) { create(:support_case) }

  before do
    click_button "Agent Login"
    visit support_case_path(support_case)
    click_on "Messages"
  end

  context "when there are no emails from the school" do
    it "shows the email text box in the messages tab" do
      find("span", text: "Send New Message").click
      expect(page).to have_field "Your message"
    end

    describe "sending a message", js: true do
      before do
        send_message_service = double("send_message_service")

        allow(send_message_service).to receive(:call) do
          email = create(:support_email, :sent_items, case: support_case, unique_body: "This is a test message", sender: { name: "Caseworker", address: agent.email })
          create(:support_interaction, :email_to_school, case: support_case, additional_data: { email_id: email.id })
        end

        allow(Support::Messages::Outlook::SendNewMessage).to receive(:new).and_return(send_message_service)
      end

      it "shows the reply" do
        click_link "Messages"
        find("span", text: "Send New Message").click
        fill_in_editor "Your message", with: "This is a test message"
        click_button "Send message"
        click_link "Messages"
        click_link "View"

        within("#messages") do
          expect(page).to have_text "Caseworker"
          expect(page).to have_text "This is a test message"
        end
      end
    end
  end
end
