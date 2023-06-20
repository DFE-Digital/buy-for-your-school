describe "Agent can send new emails", js: true do
  include_context "with an agent"

  let(:support_case) { create(:support_case, email: "contact@email.com") }

  before do
    visit support_case_path(support_case)
    click_on "Messages"
  end

  it "shows the new thread button" do
    expect(page).to have_link "Create a new message thread"
  end

  describe "creating a new thread", js: true do
    before do
      click_link "Create a new message thread"
      to_input = find("input[name$='[to]']")
      to_input.fill_in with: "to@email.com"
      to_add_button = find("button[data-input-field$='[to]']")
      to_add_button.click

      click_on "Show BCC"
      bcc_input = find("input[name$='[bcc]']")
      bcc_input.fill_in with: "bcc@email.com"
      bcc_add_button = find("button[data-input-field$='[bcc]']")
      bcc_add_button.click

      click_on "Show CC"
      cc_input = find("input[name$='[cc]']")
      cc_input.fill_in with: "cc@email.com"
      cc_add_button = find("button[data-input-field$='[cc]']")
      cc_add_button.click
    end

    it "pre-fills the default subject line" do
      expect(page).to have_field "Enter an email subject", with: "Case 000001 – DfE Get help buying for schools: your request for advice and guidance"
    end

    it "shows added recipients" do
      to_table = find("table[data-row-label='TO']")
      within(to_table) do
        # case email added by default
        expect(page).to have_text "contact@email.com"
        expect(page).to have_text "to@email.com"
      end

      cc_table = find("table[data-row-label='CC']")
      within(cc_table) do
        expect(page).to have_text "cc@email.com"
      end

      bcc_table = find("table[data-row-label='BCC']")
      within(bcc_table) do
        expect(page).to have_text "bcc@email.com"
      end
    end

    context "when a new message is sent" do
      before do
        send_message_service = double("send_message_service")

        allow(send_message_service).to receive(:call) do
          email = create(:support_email, :sent_items, case: support_case, unique_body: "This is a test message", subject: "Case 000001 – DfE Get help buying for schools: your request for advice and guidance", sender: { name: "Caseworker", address: agent.email }, recipients: [{ name: "to@email.com", address: "to@email.com" }, { name: "cc@email.com", address: "cc@email.com" }, { name: "bcc@email.com", address: "bcc@email.com" }])
          create(:support_interaction, :email_to_school, case: support_case, additional_data: { email_id: email.id })
        end

        allow(Support::Messages::Outlook::SendNewMessage).to receive(:new).and_return(send_message_service)
        click_on "Send message"
      end

      it "shows the message" do
        within("#messages") do
          expect(page).to have_text "bcc@email.com, cc@email.com, to@email.com"
          expect(page).to have_text "Case 000001 – DfE Get help buying for schools: your request for advice and guidance"
        end
      end

      it "transitions the case to on-hold" do
        expect(page).to have_text "On Hold"
      end
    end
  end
end
